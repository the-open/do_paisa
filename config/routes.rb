Rails.application.routes.draw do

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
