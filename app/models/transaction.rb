class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :recurring_donor, optional: true
  belongs_to :donor

  validates_presence_of :amount, :external_id, :status, :processor_id

  after_save :notify_webhooks, if: :transaction_successful?

  def transaction_successful?
    ['succeeded', 'Approved'].include?(status)
  end

  def notify_webhooks
    webhooks = OutgoingWebhook.where(processor_id: processor_id).or(OutgoingWebhook.where(processor_id: nil))
    webhooks.each do |webhook|
      webhook.notify(self)
    end
  end
end
