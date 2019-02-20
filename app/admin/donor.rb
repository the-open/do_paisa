ActiveAdmin.register Donor do
  config.sort_order = 'created_at_desc'
  actions :index, :show
  filter :email_cont, label: 'EMAIL', as: :string
  filter :first_name_cont, label: 'FIRST NAME', as: :string
  filter :last_name_cont, label: 'LAST NAME', as: :string
  filter :external_id_cont, label: 'EXTERNAL ID', as: :string
  filter :created_at

  index do
    column :id do |donor|
      link_to(donor.id, admin_donor_path(donor))
    end 
    column :processor
    column :external_id
    column :token
    column :created_at
    column :email do |donor|
      donor.metadata['email']
    end
    column :name do |donor|
      donor.metadata['first_name'].present? ? "#{donor.metadata['first_name']} #{donor.metadata['last_name']}" : 'No name found'
    end
    actions
  end

  show do
    panel "Donor details" do
      attributes_table_for donor do
        row :id
        row :processor_id
        row :external_id
        row :metadata
        row :data
        row :source_system
        row :source_external_id
        row :created_at
        row :updated_at
      end
    end

    panel 'Donor Transactions' do
      table_for donor.transactions do
        column('Transaction ID') { |t| link_to(t.id, admin_transaction_path(t)) }
        column('Charge Date') { |t| t.created_at.to_date }
        column('Amount') { |t| number_to_currency(t.amount/100) }
        column('Processor') { |t| t.processor.name }
        column('Recurring?') { |t| t.recurring }
      end
    end
  end
end
