class ChangeJsonToJsonb < ActiveRecord::Migration[5.1]
  def up
    change_column :donors, :metadata, :jsonb
    change_column :donors, :data, :jsonb
    change_column :processors, :config, :jsonb
    change_column :transactions, :data, :jsonb
  end
  def down
    change_column :donors, :metadata, :json
    change_column :donors, :data, :json
    change_column :processors, :config, :json
    change_column :transactions, :data, :json
  end
end
