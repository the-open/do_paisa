require File.join(Rails.root, 'spec', 'support', 'stripe_helper')

describe StripeProcessor do
  before do 
    @stripe_processor = FactoryBot.create(:stripe_processor)
    @stripe_processor.update_attributes(api_secret: ENV['STRIPE_TEST_SECRET_KEY'])
  end

  describe '#process' do
    it "charges" do 
      token = get_stripe_token
      options = {
        token: token.id,
        amount: 1200,
        metadata: ActionController::Parameters.new({}),
        source: { system: 'act', external_id: 53 },
        recurring: false      
      }

      result = @stripe_processor.process(options)

      expect(result[:status]).to eq('success')
    end

    it "doesn't charge the same card twice with the same idempotency key" do 
      token = get_stripe_token
      idempotency_key = SecureRandom.hex(16)

      options = {
        token: token.id,
        amount: 1200,
        metadata: ActionController::Parameters.new({}),
        source: { system: 'act', external_id: 53 },
        recurring: false,
        idempotency_key: idempotency_key
      }

      result1 = @stripe_processor.process(options)
      result2 = @stripe_processor.process(options)

      expect(result1[:processor_transaction_id]).to eq(result2[:processor_transaction_id])
    end
  end
end