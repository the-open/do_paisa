# frozen_string_literal: true

# This allows us to uniquely identify a given donation as coming from a campaign within multiple systems.
# If no source is passed to the transaction then we will fall back and use the donor source
class AddSourcesToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :source_system, :text, null: false
    add_column :transactions, :source_external_id, :text, null: false

    add_column :donors, :source_system, :text, null: false
    add_column :donors, :source_external_id, :text, null: false
  end
end
