class WebhookController < ApiController
  def process_webhook
    webhook = IncomingWebhook.find_by(id: params[:id])
    webhook.processor.process_webhook(params)
    render body: nil, status: 200
  end
end
