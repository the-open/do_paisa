describe Transaction do
  before do 
    @stripe_processor = FactoryBot.create(:stripe_processor_with_donor)
    @donor = @stripe_processor.donors.first
    @recurring_donor = RecurringDonor.create!(donor: @donor, processor: @stripe_processor, amount: 4201)
    @success_hash = {
      donor: @donor,
      processor: @stripe_processor,
      amount: 4201,
      status: 'approved',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187'
    }
    @fail_hash = {
      donor: @donor,
      processor: @stripe_processor,
      amount: 4201,
      status: 'rejected',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187'
    }
    Transaction.any_instance.stub(:notify_webhooks)
  end

  it "Sends a webhook if the transaction was successful" do 
    expect_any_instance_of(Transaction).to receive(:notify_webhooks).and_call_original
    @stripe_processor.outgoing_webhooks << OutgoingWebhook.create!(system: 'identity', url: 'https://test.example.com/one_off_webhook')

    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/one_off_webhook') { |env| [200, {}, ''] }
    end
    fake_faraday = Faraday.new do |builder|
      builder.adapter :test, stubs
    end

    expect(Faraday).to receive(:new).with(url: 'https://test.example.com/one_off_webhook').and_return(fake_faraday)
    Transaction.create!(@success_hash) 
  end

  it "Doesn't send a webhook if the transaction was unsuccessful" do 
    expect_any_instance_of(Transaction).not_to receive(:notify_webhooks)
    Transaction.create!(@fail_hash)  
  end

  context "notification emails" do 
    it "if one-off successful, sends an email" do
      expect(NotificationMailer).to receive(:with).and_call_original
      Transaction.create!(@success_hash) 
    end

    it "if one-off unsuccessful, doesn't send an email" do
      expect(NotificationMailer).not_to receive(:with).and_call_original
      Transaction.create!(@fail_hash) 
    end

    it "if recurring successful, doesn't send an email" do
      expect(NotificationMailer).not_to receive(:with).and_call_original
      Transaction.create!(@success_hash.merge(recurring_donor: @recurring_donor)) 
    end

    it "if recurring unsuccessful, sends an email" do
      expect(NotificationMailer).to receive(:with).and_call_original
      Transaction.create!(@fail_hash.merge(recurring_donor: @recurring_donor)) 
    end

    it "Doesn't send an email when transaction updated" do 
      transaction = Transaction.create!(@success_hash) 
      expect(NotificationMailer).not_to receive(:with).and_call_original
      transaction.touch
    end
  end
end