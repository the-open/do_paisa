ActiveAdmin.register Transaction do
  config.sort_order = 'updated_at_desc'
  actions :index, :show
  preserve_default_filters!
  remove_filter :donor, :recurring_donor, :external_id, :source_system, :source_external_id
  filter :donor_email, as: :string
  filter :donor_name, as: :string
  member_action :refund, method: :put do
    processor = Processor.find(resource.processor_id)
    processor.refund(resource.external_id)
    redirect_to admin_transaction_path, notice: "Transaction has been refunded"
  end
  action_item :refund, :only => [:show] , :if => proc { transaction.status != 'refunded' } do
    link_to "Refund Transaction", refund_admin_transaction_path(transaction), method: :put
  end
end
