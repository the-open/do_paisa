class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.uuid :processor_id
      t.string :external_id
      t.text :data
      t.bigint :amount
      t.string :status

      t.timestamps
    end
  end
end
