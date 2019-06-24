ActiveAdmin.register Transaction do
  config.sort_order = 'updated_at_desc'
  actions :index, :show

  index do
    column :id do |transaction|
      link_to(transaction.id, admin_transaction_path(transaction))
    end
    column :processor
    column :external_id
    column :created_at
    column :updated_at
    column :amount do |amount|
      number_to_currency(amount.amount / 100)
    end
    column :status
    column :recurring_donor
    column :recurring
    column :donor do |transaction|
      transaction&.donor&.metadata&.dig('email')
    end
    actions
  end

  filter :donor_email_cont, label: 'DONOR EMAIL', as: :string
  filter :donor_first_name_cont, label: 'DONOR FIRST NAME', as: :string
  filter :donor_last_name_cont, label: 'DONOR LAST NAME', as: :string
  filter :external_id_cont, label: 'EXTERNAL ID', as: :string
  filter :processor
  filter :amount_eq, label: 'AMOUNT IN CENTS'
  filter :recurring

  member_action :refund_payment, method: :put do
    processor = Processor.find(resource.processor_id)
    processor.refund(resource.external_id)
    redirect_to admin_transaction_path, notice: 'Transaction has been refunded'
  end
  action_item :refund, only: [:show], if: proc {
                                            transaction.status == 'approved' && transaction.processor.type != 'PaypalProcessor'
                                          } do
    link_to 'Refund Transaction', refund_payment_admin_transaction_path(transaction), method: :put
  end
end
