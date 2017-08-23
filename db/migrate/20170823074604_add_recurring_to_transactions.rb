class AddRecurringToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :recurring, :boolean
  end
end
