class AddProcessorIdToRecurringDonor < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_donors, :processor_id, :uuid
  end
end
