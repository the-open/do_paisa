class AddProcessorEmailTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :processor_email_templates do |t|
      t.uuid :processor_id, references: :processors, null: false, index: true
      t.integer :email_type, null: false
      t.text :html, null: false, blank: false
      t.text :subject, null: false, blank: false
      t.text :sender_name, null: false, blank: false
      t.text :sender_email, null: false, blank: false
      t.timestamps
    end

    create_table :settings do |t|
      t.text :key, null: false, index: true
      t.text :value
      t.timestamps
    end

    create_table :donor_emails do |t|
      t.uuid :donor_id, references: :donors, null: false, index: true
      t.text :html, null: false, blank: false
      t.text :subject, null: false, blank: false
      t.text :sender_name, null: false, blank: false
      t.text :sender_email, null: false, blank: false
      t.text :status
      t.text :external_id
      t.timestamp :opened_at
      t.timestamp :clicked_at
      t.timestamps
    end
  end
end
