describe Transaction do
  before do 
    @stripe_processor = FactoryBot.create(:stripe_processor_with_donor)
    @donor = @stripe_processor.donors.first
    Transaction.any_instance.stub(:notify_webhooks)
  end

  it "Sends a webhook if the transaction was successful" do 
    expect_any_instance_of(Transaction).to receive(:notify_webhooks)
    Transaction.create!(
      donor: @donor,
      processor: @stripe_processor,
      amount: 4201,
      status: 'succeeded',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187'
      ) 
  end

  it "Doesn't send a webhook if the transaction was unsuccessful" do 
    expect_any_instance_of(Transaction).not_to receive(:notify_webhooks)
    Transaction.create!(
      donor: @donor,
      processor: @stripe_processor,
      amount: 4201,
      status: 'failed',
      external_id: SecureRandom.hex(32),
      source_system: 'act',
      source_external_id: '187'
      )  
  end
end