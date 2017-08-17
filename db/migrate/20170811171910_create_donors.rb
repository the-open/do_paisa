class CreateDonors < ActiveRecord::Migration[5.1]
  def change
    create_table :donors, id: :uuid do |t|
      t.uuid :processor_id
      t.string :external_id
      t.string :token

      t.timestamps
    end
  end
end
