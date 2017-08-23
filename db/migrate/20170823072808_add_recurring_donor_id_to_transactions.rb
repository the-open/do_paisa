class AddRecurringDonorIdToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :recurring_donor_id, :uuid
  end
end
