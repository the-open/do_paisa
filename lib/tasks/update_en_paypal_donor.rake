# frozen_string_literal: true
require 'open-uri'

def update_donors(csv)
  csv_string = open(URI.encode(import_csv), 'r').read.force_encoding('UTF-8')
  csv = CSV.parse(csv_string, headers: true)

  csv.each do |row|
    donor = Donor.find_by("metadata->>'en_id' =  ?", row['smartdebit_reference'])
    unless donor
      raise "Failed to find paypal donor with en_id: #{row['smartdebit_reference']}"
    end

    donor.metadata['identity_external_id'] = row['external_id']
    donor.save!
  end
end

desc 'This task updates EN PayPal donors with an external id merged into donor metadata'
task :update_en_paypal_donors, [:paypal_donors_csv] => :environment do |_, args|
  puts "Beginning import...\n"
  update_donors(args.paypal_donors_csv)
end
