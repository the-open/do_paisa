class IncomingWebhook < Webhook
  belongs_to :processor, optional: false
end
