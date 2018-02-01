# frozen_string_literal: true

# This allows us to uniquely identify a given donation as coming from a campaign within multiple systems.
# If no source is passed to the transaction then we will fall back and use the donor source
class AddSourcesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :source_system, :text
    add_column :transactions, :source_external_id, :text

    add_column :donors, :source_system, :text
    add_column :donors, :source_external_id, :text

    Transaction.all.update_all(source_system: 'unknown', source_external_id: 'unknown')
    Donor.all.update_all(source_system: 'unknown', source_external_id: 'unknown')

    change_column_null :transactions, :source_system, false
    change_column_null :transactions, :source_external_id, false
    change_column_null :donors, :source_system, false
    change_column_null :donors, :source_external_id, false
  end
end
