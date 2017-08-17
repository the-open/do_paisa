class AddMetadataToDonor < ActiveRecord::Migration[5.1]
  def change
    add_column :donors, :metadata, :json
  end
end
