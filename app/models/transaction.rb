class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :recurring_donor, optional: true
  belongs_to :donor

  validates_presence_of :amount, :external_id, :status, :processor_id

  after_commit :notify_webhooks, if: :transaction_successful?, on: :create
  after_commit :notify_email, on: :create

  def transaction_successful?
    ['succeeded', 'Approved'].include?(status)
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify(self)
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
