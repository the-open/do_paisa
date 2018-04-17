ActiveAdmin.register Donor do
  actions :index, :show
  filter :email, as: :string
  filter :name, as: :string
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :processor_id
      row :external_id
      row :metadata
      row :data
      row :source_system
      row :source_external_id
      row :created_at
      row :updated_at
      panel 'Transactions' do
        table_for donor.transactions do
          column('Transaction ID') { |t| link_to(t.id, admin_transaction_path(t)) }
          column('Charge Date') { |t| t.created_at.to_date }
          column('Amount') { |t| t.amount }
          column('Processor') { |t| t.processor.name }
          column('Recurring?') { |t| t.recurring }
        end
      end
    end
    active_admin_comments
  end
end
