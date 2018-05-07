# frozen_string_literal: true

class OutgoingWebhook < Webhook
  belongs_to :processor, optional: true

  def notify_transaction(transaction)
    webhook_payload = WebhookPayload.new(self.system, transaction)
    body = webhook_payload.get_payload.to_json

    connection = Faraday.new(url: url)
    connection.post do |request|
      request.url url
      request.headers['Content-Type'] = 'application/json'
      request.body = body
    end
  end
end
