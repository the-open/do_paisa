ActiveAdmin.register IatsProcessor do
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

  show do
    attributes_table do
      row :name
      row :id
      row :currency
      row :api_key
      row :config
      row :created_at
      row :updated_at
    end

    panel "Email Templates" do
      table_for(resource.processor_email_templates) do |table|
        column("email_type") { |pet| link_to pet.email_type.titleize, admin_processor_email_template_path(pet) }
        column("subject") { |pet| pet.subject }
      end
    end
  end
end