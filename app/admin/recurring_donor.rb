ActiveAdmin.register RecurringDonor do
  config.sort_order = 'next_charge_at_desc'
  actions :all, :except => [:destroy]
  permit_params :ended_at
  
  preserve_default_filters!
  remove_filter :donor
  filter :transactions, label: 'Transaction ID', collection: -> {
    Transaction.all.map { |t| [t.id] }
  }
  filter :donor_email, as: :string
  filter :donor_name, as: :string

  form do |f|
    f.inputs do
      f.input :ended_at, as: :datepicker,
                        datepicker_options: {
                          min_date: "Date.today.to_s",
                          max_date: "+3Y"
                        }
    end
    f.actions
  end
end
