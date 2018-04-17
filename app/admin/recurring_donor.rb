ActiveAdmin.register RecurringDonor do
  actions :index, :show
  preserve_default_filters!
  remove_filter :donor
  filter :transactions, label: 'Transaction ID', collection: -> {
    Transaction.all.map { |t| [t.id] }
  }
  filter :donor_email, as: :string
  filter :donor_name, as: :string
end
