class CreateWebhooks < ActiveRecord::Migration[5.1]
  def change
    create_table :webhooks, id: :uuid do |t|
      t.string :name
      t.uuid :processor_id
      t.string :url
      t.string :type

      t.timestamps
    end
  end
end
