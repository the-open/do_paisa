# frozen_string_literal: true

class OutgoingWebhook < Webhook
  belongs_to :processor, optional: true

  def notify_transaction(transaction)
    payload = WebhookPayload.new(self.system, transaction).get_payload
    post_payload(payload, url)
  end

  def notify_recurring(recurring_donor)
    payload = RecurringWebhookPayload.new(self.system, recurring_donor).get_payload
    post_payload(payload, recurring_url)    
  end

  def post_payload(payload, api_url)
    json_payload = payload.to_json

    connection = Faraday.new(url: api_url)
    connection.post do |request|
      request.url api_url
      request.headers['Content-Type'] = 'application/json'
      request.body = json_payload
    end
  end
end
