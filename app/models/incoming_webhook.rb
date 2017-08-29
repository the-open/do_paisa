class IncomingWebhook < Webhook
  include Rails.application.routes.url_helpers
  belongs_to :processor, optional: false

  after_create :generate_url

  def generate_url
    self.url = webhook_path(self)
    save!
  end
end
