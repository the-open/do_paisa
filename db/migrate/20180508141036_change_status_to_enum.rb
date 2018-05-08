class ChangeStatusToEnum < ActiveRecord::Migration[5.1]
  def up
    change_column :transactions, :status, "integer USING (CASE status WHEN 'pending' THEN '0'::integer WHEN 'approved' THEN '1'::integer WHEN 'rejected' THEN '2'::integer WHEN 'returned' THEN '3' END)", null: false, default: 0
  end
  def down
    change_column :transactions, :status, "string USING (CASE status WHEN '0' THEN 'pending'::string WHEN '1' THEN 'approved'::string WHEN '2' THEN 'rejected'::string WHEN '3' THEN 'returned' END)", null: false, default: 'init'
  end
end
