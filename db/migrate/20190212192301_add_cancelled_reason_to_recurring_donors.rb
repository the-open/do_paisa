class AddCancelledReasonToRecurringDonors < ActiveRecord::Migration[5.1]
  def up
    add_column :recurring_donors, :cancelled_reason, :string
  end

  def down
    remove_column :recurring_donors, :cancelled_reason, :string
  end
end
