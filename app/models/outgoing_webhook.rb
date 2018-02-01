# frozen_string_literal: true

class OutgoingWebhook < Webhook
  include WebhookPayload
  belongs_to :processor, optional: true

  def notify(transaction)
    body = get_webhook_payload(self, transaction).to_json

    connection = Faraday.new(url: url)
    connection.post do |request|
      request.url url
      request.headers['Content-Type'] = 'application/json'
      request.body = body
    end
  end
end
