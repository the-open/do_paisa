def due_date(date)
  day = Date.parse(date).strftime("%d")
  day > Date.today.strftime("%d") ? Date.parse(date) : Date.parse(date) + 1.month
end

def parse_csv(import_csv)
  CSV.foreach(import_csv, headers: true) do |row|
    options = {
      source: {
        system: 'caft import'
      },
      recurring: true,
      amount: row['amount'],
      metadata: {
        first_name: row['first_name'],
        last_name: row['last_name'],
        account_number: row['route'] + row['transit'] + row['account_no']
      },
      date: due_date(row['due_date'])
    }
    processor = IatsProcessor.find(ENV['IATS_UUID'])

    success, donor = processor.add_donor(options[:metadata], options[:source]) unless donor

    if success
      processor.add_recurring_donor(donor, options[:amount], options[:date])
    else
      return {
        error: 'This is a fail'
      }
    end
  end
end

desc 'This task imports CAFT Donors from a CSV to the iATs processor'
task :import_caft_from_csv, [:donors_csv] => :environment do |_, args|
  puts "Beginning import...\n"
  parse_csv(args.donors_csv)
end
