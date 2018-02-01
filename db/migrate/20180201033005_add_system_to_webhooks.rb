# frozen_string_literal: true

class AddSystemToWebhooks < ActiveRecord::Migration[5.1]
  def change
    add_column :webhooks, :system, :text
  end
end
