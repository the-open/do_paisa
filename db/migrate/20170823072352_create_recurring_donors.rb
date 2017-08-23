class CreateRecurringDonors < ActiveRecord::Migration[5.1]
  def change
    create_table :recurring_donors, id: :uuid do |t|
      t.uuid :donor_id
      t.bigint :amount
      t.date :last_charged_at
      t.date :next_charge_at

      t.timestamps
    end
  end
end
