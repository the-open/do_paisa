class AddDataToDonor < ActiveRecord::Migration[5.1]
  def change
    add_column :donors, :data, :json
  end
end
