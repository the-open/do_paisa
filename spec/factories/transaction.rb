FactoryBot.define do
  factory :transaction do
    external_id { SecureRandom.hex(16) }
    status 'success'
    source_external_id { SecureRandom.hex(16) }
    source_system 'act'
  end
end
