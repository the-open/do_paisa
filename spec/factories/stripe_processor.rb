FactoryBot.define do
  factory :stripe_processor do
    name ENV['STRIPE_PROCESSOR_NAME']
    api_key { SecureRandom.hex(32) }
    api_secret { SecureRandom.hex(32) }
    currency 'cad'
    
    factory :stripe_processor_with_donor do 
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
        create(:transaction, processor: processor, donor: donor, amount: rand(10000) )
      end
    end

    factory :stripe_processor_with_po_donor do
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
        donor.update_attributes!(
          metadata: {
                    name: donor.metadata['name'],
                    email: donor.metadata['email'],
                    postcode: donor.metadata['postcode'],
                    country: donor.metadata['country'],
                    po_guid: 'r2df2481-snmt-1afc-16e2-1k2fp19ueq3cg'
                    }
        )
        create(:transaction, processor: processor, donor: donor, amount: rand(10000) )
      end
    end

    factory :stripe_processor_with_recurring_donor do 
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
        create(:recurring_donor, processor: processor, donor: donor, amount: rand(10000) )
      end
    end
  end
end
