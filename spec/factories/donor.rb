FactoryBot.define do
  factory :donor do 
    external_id { SecureRandom.hex(32) }
    token { SecureRandom.hex(32) }
    source_system { Faker::App.name }
    source_external_id { Faker::Number.number(4).to_s }
    metadata {
      {
        'name' => Faker::Name.name,
        'email' => Faker::Internet.email,
        'postcode' => Faker::Address.postcode,
        'country' => Faker::Address.country_code
      }
    }
  end
end