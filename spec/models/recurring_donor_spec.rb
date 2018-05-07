describe RecurringDonor do
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