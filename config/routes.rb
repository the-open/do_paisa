
Rails.application.routes.draw do
  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end
  mount Sidekiq::Web, at: '/sidekiq'

  # Return 404 at root path
  get '/', to: proc { [404, {}, ['']] }

  # Auth0
  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure'        => 'auth0#failure'

  # webhooks
  match '/webhooks/:id', to: 'webhook#process_webhook', via: :post, as: 'webhook'

  # payments
  match '/payments/:id/pay', to: 'payments#pay', via: %i[get post], as: 'pay'
  match '/processors/:id/example', to: 'processor#example', via: :get, as: 'example'

  # admin
  ActiveAdmin.routes(self)
  match '/admin/login', to: 'auth0#login', via: :get
  match '/admin/logout', to: 'auth0#logout', via: :get
end
