def due_date(date)
  day = Date.parse(date).strftime("%d")
  day > Date.today.strftime("%d") ? Date.parse(date) : Date.parse(date) + 1.month
end

def parse_csv(import_csv, processor)
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

    success, donor = processor.add_donor(options[:metadata], options[:source])

    if success
      processor.add_recurring_donor(donor, options[:amount], options[:date])
    else
      puts "Failed to create donor for #{row['first_name']} #{row['last_name']}"
    end
  end
end

desc 'This task imports CAFT Donors from a CSV to the iATs processor'
task :import_caft_from_csv, [:donors_csv, :processor_id] => :environment do |_, args|
  puts "Beginning import...\n"
  processor = IatsProcessor.find_by(id: args.processor_id)
  parse_csv(args.donors_csv, processor)
end
