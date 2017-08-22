class CreateApiUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :api_users, id: :uuid do |t|
      t.string :name
      t.string :key
      t.string :allowed_origin

      t.timestamps
    end
  end
end
