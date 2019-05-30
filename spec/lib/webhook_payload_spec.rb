require 'rails_helper'

describe WebhookPayload do
  before do
    @stripe_processor = FactoryBot.create(:stripe_processor)
    @donor = Donor.create!(
      processor: @stripe_processor,
      external_id: SecureRandom.hex(32),
      token: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '67',
      metadata: {
        'first_name' => 'Johnny',
        'last_name' => 'Bravo',
        'email' => 'test@example.com',
        'address_zip' => 'HP5 3LR',
        'address_country' => 'GB'
      }
    )

    Transaction.any_instance.stub(:notify_webhooks)
    @transaction = Transaction.create!(
      processor: @stripe_processor,
      donor: @donor,
      amount: 1045,
      status: 'approved',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187',
      created_at: Time.now
    )

    @expected_payload = {
      system: 'do_paisa',
      external_id: @transaction.id,
      email: 'test@example.com',
      first_name: 'Johnny',
      last_name: 'Bravo',
      postcode: 'HP5 3LR',
      country: 'GB',
      created_at: @transaction.created_at,
      amount: '10.45',
      card_brand: 'unknown',
      source: '187|act',
      source_system: 'act',
      source_external_id: '187',
      api_token: 'abcd1234',
      status: 'approved',
      medium: @stripe_processor.name
    }
    Rails.application.secrets.stub(:identity_api_token) { 'abcd1234' }
  end

  it 'Correctly generates an Identity Webhook' do
    payload = WebhookPayload.new('identity', @transaction, @stripe_processor).get_payload
    expect(payload).to eq(@expected_payload)
  end

  it 'Includes the correct recurring donation data' do
    recurring_donor = RecurringDonor.create!(donor: @donor, processor: @stripe_processor, amount: 4201)
    @transaction.update(recurring_donor: recurring_donor)
    payload = WebhookPayload.new('identity', @transaction, @stripe_processor).get_payload
    @expected_payload[:regular_donation_external_id] = recurring_donor.id
    @expected_payload[:regular_donation_system] = @stripe_processor.name

    expect(payload).to eq(@expected_payload)
  end
end
