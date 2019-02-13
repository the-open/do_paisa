ActiveAdmin.register RecurringDonor do
  config.sort_order = 'next_charge_at_desc'
  actions :all, :except => [:new, :destroy]
  permit_params :ended_at, :cancelled_reason
  
  filter :donor_email_cont, label: 'DONOR EMAIL', as: :string
  filter :donor_first_name_cont, label: 'DONOR FIRST NAME', as: :string
  filter :donor_last_name_cont, label: 'DONOR LAST NAME', as: :string
  filter :processor
  filter :amount_eq, label: 'AMOUNT IN CENTS'

  index do
    column :id do |recurring_donor|
      link_to(recurring_donor.id, admin_recurring_donor_path(recurring_donor))
    end 
    column :donor
    column :processor
    column :amount do |amount|
      number_to_currency(amount.amount/100)
    end
    column :last_charged_at
    column :next_charge_at
    column :created_at
    column :ended_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :ended_at, as: :datepicker
      f.input :cancelled_reason, :as => :select, required: true, collection: [
        "Can't afford to donate", 
        "Doesn't like Leadnow",
        "Multiple donations",
        "Other"
      ]
    end
    f.actions
  end

  show do
    
    panel "Recurring Donor Details" do
      attributes_table_for recurring_donor do
        row :amount
        row :last_charged_at
        row :next_charge_at
        row :created_at
        row :updated_at
        row :processor
        row :created_at
        row :updated_at
        row :ended_at if recurring_donor.ended_at.present?
        row :last_fail_reason if recurring_donor.last_fail_reason.present?
        row :cancelled_reason if recurring_donor.cancelled_reason.present?
      end
    end

    panel 'Donor Transactions' do
      table_for recurring_donor.donor.transactions do
        column('Transaction ID') { |t| link_to(t.id, admin_transaction_path(t)) }
        column('Charge Date') { |t| t.created_at.to_date }
        column('Amount') { |t| number_to_currency(t.amount/100) }
        column('Processor') { |t| t.processor.name }
        column('Recurring?') { |t| t.recurring }
      end
    end
  end

  sidebar "Donor Details", only: :show do
    attributes_table_for recurring_donor.donor do
      row('Email') { |d| d.metadata['email'] }
      row('Name') { |d| d.metadata['first_name'] + ' ' + d.metadata['last_name'] }
      row('Donor ID') { |d| link_to(d.id, admin_donor_path(d)) }
    end
  end
end
