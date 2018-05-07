describe RecurringWebhookPayload do
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
    RecurringDonor.any_instance.stub(:notify_webhooks)
    @recurring_donor = RecurringDonor.create!(donor: @donor, processor: @stripe_processor, amount: 4201)

    @expected_payload = {
      api_token: "abcd1234", 
      cons_hash: {
        firstname: "Johnny", 
        lastname: "Bravo", 
        emails: [{ email: "test@example.com"}], 
        addresses: [
          { 
            line1: nil, 
            line2: nil, 
            town: nil, 
            state: nil, 
            postcode: "HP5 3LR", 
            country: "GB"
          }
        ]
      },
      medium: "do_paisa", 
      external_id: @recurring_donor.id,
      started_at: @recurring_donor.created_at, 
      current_amount: 42.01
    }
    Rails.application.secrets.stub(:identity_api_token) { 'abcd1234' }
  end

  it 'Correctly generates an Identity Webhook' do
    payload = RecurringWebhookPayload.new('identity', @recurring_donor).get_payload
    expect(payload).to eq(@expected_payload)
  end
end