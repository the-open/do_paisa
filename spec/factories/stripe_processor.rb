# frozen_string_literal: true

FactoryBot.define do
  factory :stripe_processor do
    name 'Test processor'
    api_key { SecureRandom.hex(32) }
    api_secret { SecureRandom.hex(32) }
    currency 'cad'
  end
end
