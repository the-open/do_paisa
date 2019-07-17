class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :recurring_donor, optional: true
  belongs_to :donor

  enum status: { pending: 0, approved: 1, rejected: 2, returned: 3, refunded: 4 }

  validates_presence_of :amount, :external_id, :status, :processor_id

  after_commit :notify_email_approved, if: :should_send_email_approved?
  after_commit :notify_email_pending, if: :should_send_email_pending?
  after_commit :notify_email_rejected, if: :should_send_email_rejected?
  after_commit :notify_webhooks, if: :should_send_webhook?

  def should_send_webhook?
    return if processor.type == 'PaypalProcessor'
    (transaction_successful? || transaction_returned_or_refunded?) && saved_change_to_status?
  end

  def should_send_email_approved?
    transaction_successful? && saved_change_to_id? && saved_change_to_status?
  end

  def notify_email_approved
    NotificationMailer.with(transaction_id: id).one_off_approved.deliver_later(wait: 5.minutes) unless recurring_donor
    post_to_slack
  end

  def should_send_email_pending?
    status == 'pending' && saved_change_to_id?
  end

  def notify_email_pending
    NotificationMailer.with(transaction_id: id).one_off_pending.deliver_later(wait: 5.minutes) unless recurring_donor
  end

  def should_send_email_rejected?
    # If it's not new, or if it's part of a recurring payment
    (!saved_change_to_id? || recurring_donor) && status == 'rejected' && saved_change_to_status?
  end

  def notify_email_rejected
    if recurring_donor
      NotificationMailer.with(transaction_id: id).recurring_fail.deliver_later(wait: 5.minutes)
    else
      NotificationMailer.with(transaction_id: id).one_off_pending_rejected.deliver_later(wait: 5.minutes)
    end
  end

  def transaction_successful?
    status == 'approved'
  end

  def transaction_returned_or_refunded?
    %w[returned refunded].include? status
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify_transaction(self, processor)
    end
  end

  def post_to_slack
    return unless amount >= 50_000

    Slack.new.post_message ":rotating_light: \t :rotating_light: \t :rotating_light: \t :rotating_light: \n <!channel> A $#{amount / 100} donation with transaction id: #{id} from #{donor.metadata['email']} has just been made \n :rotating_light: \t :rotating_light: \t :rotating_light: \t :rotating_light:"
  end
end
