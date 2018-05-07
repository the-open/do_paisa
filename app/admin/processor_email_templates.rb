ActiveAdmin.register ProcessorEmailTemplate do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :html, :subject, :sender_email, :sender_name, :email_type, :processor_id

  form do |f|
    f.inputs do
      f.input :processor
      f.input :email_type
      f.input :sender_name, as: :string
      f.input :sender_email, as: :string
      f.input :subject, as: :string
      f.input :html
      f.label "Available personalisation tags: {{first_name}}, {{last_name}}, {{email}}, {{amount}}, {{next_charge_at}}, {{last_fail_reason}}".html_safe
    end
    f.actions
  end

end
