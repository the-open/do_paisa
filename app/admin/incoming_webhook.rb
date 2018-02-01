ActiveAdmin.register IncomingWebhook do
  menu parent: 'Webhooks'

  permit_params :name, :processor_id

  form do |f|
    f.inputs do
      f.input :name
      f.input :system
      f.input :processor, label: 'Processor', as: :select, collection: Processor.all, include_blank: false
    end
    f.actions
  end
end
