class AddFailFieldsToRecurringDonor < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_donors, :consecutive_fail_count, :integer, null: false, default: 0
    add_column :recurring_donors, :ended_at, :timestamp
    add_column :recurring_donors, :last_fail_reason, :text
  end
end
