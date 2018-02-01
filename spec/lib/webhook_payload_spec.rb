# frozen_string_literal: true

require 'rails_helper'
include WebhookPayload

describe WebhookPayload do
  before do
    @stripe_processor = FactoryBot.create(:stripe_processor)
    @outgoing_webhook = OutgoingWebhook.create!(
      name: 'Test API',
      url: 'https://api.com/webhook',
      processor: @stripe_processor
    )
    @donor = Donor.new(
      external_id: SecureRandom.hex(32),
      token: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '67',
      metadata: {
        'name' => 'Johnny Bravo',
        'email' => 'test@example.com',
        'postcode' => 'HP5 3LR',
        'country' => 'GB'
      }
    )

    Transaction.skip_callback(:save, :after, :notify_webhooks)
    @transaction = Transaction.create!(
      processor: @stripe_processor,
      donor: @donor,
      amount: 1045,
      status: 'succeeded',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187',
      created_at: Time.now
    )
    Transaction.set_callback(:save, :after, :notify_webhooks)
  end

  it 'Correctly generates an Identity Webhook' do
    @outgoing_webhook.update_attributes(system: 'identity')

    payload = get_webhook_payload(@outgoing_webhook, @transaction)

    expect(payload).to eq(
      system: 'do_paisa',
      external_id: @transaction.id,
      email: 'test@example.com',
      first_name: 'Johnny',
      last_name: 'Bravo',
      postcode: 'HP5 3LR',
      country: 'GB',
      created_at: @transaction.created_at,
      amount: 10.45,
      card_brand: 'unknown',
      source: '187|act',
      source_system: 'act',
      source_external_id: '187'
    )
  end
end
