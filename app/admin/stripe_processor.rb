ActiveAdmin.register StripeProcessor do
  menu parent: 'Processors'

  permit_params :name, :currency, :api_key, :api_secret, :config

  form do |f|
    f.inputs do
      f.input :name
      f.input :currency
      f.input :api_key
      f.input :api_secret
      f.input :config, as: :text
    end
    f.actions
  end
end
