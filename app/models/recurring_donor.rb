class RecurringDonor < ApplicationRecord
  has_many :transactions
  belongs_to :processor
  belongs_to :donor

  validates_presence_of :amount, :donor_id, :processor_id
  after_commit :notify_webhooks, on: [:create, :update]
  after_commit :notify_email, on: :create

  def charge
    process_params = {
      token: donor.external_id,
      amount: amount,
      recurring_donor_id: id,
      idempotency_key: Digest::MD5.hexdigest("#{donor_id}:#{Date.today.month}:#{consecutive_fail_count}")
    }
    if processor.type == 'PaypalProcessor'
      process_params[:custom] = (donor.source_external_id + '|MONTHLY|' + donor.metadata['en_id'])
      process_params[:order_description] = donor.metadata['email']
    end
    response = processor.process(process_params)
    Rollbar.error(response) and return if response.nil?
    if response[:status] == 'approved'
      acknowledge_successful_transaction
    elsif response[:status] == 'rejected'
      acknowledge_failed_transaction(response[:message])
    elsif response[:status] == 'returned'
      acknowledge_returned_transaction(response[:message])
    end
  end

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

  def acknowledge_returned_transaction(message)
    codes = [60, 62, 63, 65, 72, 75, 77]
    matcher = /Return:(\d*)/
    return_code = message.scan(matcher).first.first.to_i
    if codes.include?(return_code)
      update_attributes!(
        next_charge_at: nil,
        ended_at: Time.now,
        last_fail_reason: message
      )
      notify_webhooks
    else
      acknowledge_failed_transaction(message)
    end
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify_recurring(self, self.processor)
    end
  end

  def notify_email
    NotificationMailer.with(recurring_donor: self).recurring_started.deliver_later
  end
end
