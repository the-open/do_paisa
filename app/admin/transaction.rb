ActiveAdmin.register Transaction do
  actions :index, :show
  preserve_default_filters!
  remove_filter :donor, :recurring_donor, :external_id, :source_system, :source_external_id
  filter :donor_email, as: :string
  filter :donor_name, as: :string
end
