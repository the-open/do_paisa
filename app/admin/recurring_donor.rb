ActiveAdmin.register RecurringDonor do
  actions :all, :except => [:destroy]
  permit_params :next_charge_at, :ended_at
  
  preserve_default_filters!
  remove_filter :donor
  filter :transactions, label: 'Transaction ID', collection: -> {
    Transaction.all.map { |t| [t.id] }
  }
  filter :donor_email, as: :string
  filter :donor_name, as: :string

  form do |f|
    f.inputs do
      f.input :amount
      f.input :ended_at, as: :datepicker,
                        datepicker_options: {
                          min_date: "Date.today.to_s",
                          max_date: "+3Y"
                        }
      f.input :next_charge_at, as: :datepicker,
                        datepicker_options: {
                          min_date: :next_charge_at,
                          max_date: "+1Y"
                        }
    end
    f.actions
  end
end
