class AddDonorIdToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :donor_id, :uuid
  end
end
