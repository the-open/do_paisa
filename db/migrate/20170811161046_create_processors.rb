class CreateProcessors < ActiveRecord::Migration[5.1]
  def change
    create_table :processors, id: :uuid do |t|
      t.string :type
      t.string :name
      t.string :api_key
      t.string :api_secret
      t.string :currency
      t.json :config

      t.timestamps
    end
  end
end
