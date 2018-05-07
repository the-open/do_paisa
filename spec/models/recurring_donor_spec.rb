describe RecurringDonor do
  context "sending emails" do
    it "sends an email when created" do
      expect(NotificationMailer).to receive(:with).and_call_original
      @stripe_processor = FactoryBot.create(:stripe_processor_with_recurring_donor)
    end

    context 'donor already exists' do 
      before do 
        @stripe_processor = FactoryBot.create(:stripe_processor_with_recurring_donor)
      end

      it "doesn't send an email when updated" do 
        expect(NotificationMailer).not_to receive(:with).and_call_original
        @stripe_processor.donors[0].recurring_donor.touch
      end
    end
  end

  context "Webhook integration" do 
    it "triggers a webhook to the processor's recurring_url URL" do 
      stripe_processor = FactoryBot.create(:stripe_processor_with_donor)
      stripe_processor.outgoing_webhooks << OutgoingWebhook.create!(system: 'identity', recurring_url: 'https://test.example.com/recurring_webhook')

      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.post('/recurring_webhook') { |env| [200, {}, ''] }
      end
      fake_faraday = Faraday.new do |builder|
        builder.adapter :test, stubs
      end

      expect(Faraday).to receive(:new).with(url: 'https://test.example.com/recurring_webhook').and_return(fake_faraday)
      recurring_donor = RecurringDonor.create!(donor: stripe_processor.donors.first, processor: stripe_processor, amount: 4201)
    end
  end
end