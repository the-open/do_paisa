class AddRecurringWebhookUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :webhooks, :recurring_url, :text
  end
end
