# frozen_string_literal: true

namespace :en do
  def create_donors(csv, processor)
    CSV.foreach(csv, headers: true) do |row|
      token = row['Campaign Data 2']

      metadata = {
        email: row['Supporter Email'],
        en_id: row['Supporter ID'],
        campaign_id: row['Campaign ID'],
        campaign_date: row['Campaign Date']
      }

      source = {
        system: 'PayPal EN Import',
        external_id: row['Campaign ID']
      }

      amount = row['Campaign Data 4']

      date = Date.parse(row['Campaign Data 16']) + 1.month

      processor.add_donor(token, metadata, source, amount, date)

      puts "Imported user with email: #{metadata[:email]}"
    end
  end

  desc 'Import PayPal tokens from EN CSV Export'
  task :import_paypal_tokens, %i[csv processor_id] => :environment do |_, args|
    processor = Processor.where(id: args.processor_id).take!
    create_donors(args.csv, processor)
  end
end
