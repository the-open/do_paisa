class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :recurring_donor, optional: true
  belongs_to :donor

  enum status: { pending: 0, approved: 1, rejected: 2, returned: 3 }

  validates_presence_of :amount, :external_id, :status, :processor_id

  after_commit :notify_email, on: :create
  after_commit :notify_webhooks, if: :should_send_webhook?

  def should_send_webhook?
    transaction_successful? && saved_change_to_status?
  end

  def transaction_successful?
    ['approved', 'Approved'].include?(status)
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify_transaction(self)
    end
  end

  def notify_email
    if !recurring_donor
      if transaction_successful?
        NotificationMailer.with(transaction: self).one_off_success.deliver_later
      end
    else
      # We only notify if a recurring donation fails
      if !transaction_successful?
        NotificationMailer.with(transaction: self).recurring_fail.deliver_later
      end
    end 
  end
end
