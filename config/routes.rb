Rails.application.routes.draw do

  # webhooks
  match '/webhooks/:id', to: 'webhook#process_webhook', via: :post, as: 'webhook'

  # payments
  match '/payments/:id/pay', to: 'payments#pay', via: %i[get post], as: 'pay'

  # admin
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
