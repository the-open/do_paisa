FactoryBot.define do
  factory :stripe_processor do
    name 'Test processor'
    api_key { SecureRandom.hex(32) }
    api_secret { SecureRandom.hex(32) }
    currency 'cad'
    
    factory :stripe_processor_with_donor do 
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
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
