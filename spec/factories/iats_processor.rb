FactoryBot.define do
  factory :iats_processor do
    name 'iATs'
    api_key { 'TEST88' }
    api_secret { 'TEST88' }
    currency 'cad'
    
    factory :iats_processor_with_donor do 
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
        create(:transaction, processor: processor, donor: donor, amount: 100)
      end
    end

    factory :iats_processor_with_recurring_donor do 
      after(:create) do |processor, evaluator|
        donor = create_list(:donor, 1, processor: processor)[0]
        create(:recurring_donor, processor: processor, donor: donor, amount: 100)
      end
    end
  end
end