class RecurringDonor < ApplicationRecord
  has_many :transactions
  belongs_to :processor
  belongs_to :donor

  validates_presence_of :amount, :donor_id, :processor_id
  after_commit :notify_webhooks, on: :create
  after_commit :notify_email, on: :create

  def charge
    process_params = {
      token: donor.token,
      amount: amount,
      recurring_donor_id: id,
      idempotency_key: Digest::MD5.hexdigest("#{donor_id}:#{Date.today.month}:#{consecutive_fail_count}")
    }

    response = processor.process(process_params)

    if response[:status] == 'approved'
      acknowledge_successful_transaction
    elsif response[:status] == 'failed' 
      acknowledge_failed_transaction(response[:message])
    end
  end

  private

  def acknowledge_successful_transaction
    update_attributes!(
      last_charged_at: Date.today,
      next_charge_at: Date.today + 1.month,
      consecutive_fail_count: 0
    )
  end

  def acknowledge_failed_transaction(message)
    if consecutive_fail_count < 2
      update_attributes!(
        next_charge_at: Date.tomorrow,
        consecutive_fail_count: consecutive_fail_count + 1,
        last_fail_reason: message
      )
    else
      update_attributes!(
        next_charge_at: nil,
        ended_at: Time.now,
        consecutive_fail_count: consecutive_fail_count + 1,
        last_fail_reason: message
      )
      notify_webhooks
    end
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify_recurring(self)
    end
  end

  def notify_email
    NotificationMailer.with(recurring_donor: self).recurring_started.deliver_later
  end
end
