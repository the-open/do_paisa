FactoryBot.define do
  factory :stripe_processor do
    name 'Test processor'
    api_key { SecureRandom.hex(32) }
    api_secret { SecureRandom.hex(32) }
    currency 'cad'
    
    factory :stripe_processor_with_donor do 
      after(:create) do |processor, evaluator|
        create_list(:donor, 1, processor: processor)
      end
    end
  end
end
