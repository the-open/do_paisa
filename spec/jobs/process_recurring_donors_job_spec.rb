RSpec.describe ProcessRecurringDonorsJob, type: :job do 
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  before do 
    @stripe_processor = FactoryBot.create(:stripe_processor_with_donor)
    @donor = @stripe_processor.donors.first
    @today_donor = RecurringDonor.create!(
      donor: @donor, 
      last_charged_at: 1.month.ago, 
      next_charge_at: Date.today, 
      processor: @stripe_processor,
      amount: 1000
      )
  end

  it "Should charge only the people whose day it is" do 
    @yesterday_donor = RecurringDonor.create!(
      donor: @donor, 
      last_charged_at: 1.month.ago, 
      next_charge_at: Date.yesterday, 
      processor: @stripe_processor,
      amount: 1000
      )
    @tomorrow_donor = RecurringDonor.create!(
      donor: @donor, 
      last_charged_at: 1.month.ago, 
      next_charge_at: Date.yesterday, 
      processor: @stripe_processor,
      amount: 1000
      )
    expect_any_instance_of(StripeProcessor).to receive(:process).with(hash_including(:recurring_donor_id => @today_donor.id)).and_return(status: 'success')
    expect_any_instance_of(StripeProcessor).not_to receive(:process).with(hash_including(:recurring_donor_id => @yesterday_donor.id))
    expect_any_instance_of(StripeProcessor).not_to receive(:process).with(hash_including(:recurring_donor_id => @tomorrow_donor.id))
    
    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
  end

  it "Shouldn't charge people twice if run multiple times in same day" do 
    expect_any_instance_of(StripeProcessor).to receive(:process).exactly(1).times.with(hash_including(:recurring_donor_id => @today_donor.id)).and_return(status: 'success')

    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
  end

  it "When it fails, should update the last_failed_at column, increment the consecutive_fail_count, and set to try tomorrow" do 
    expect_any_instance_of(StripeProcessor).to receive(:process).exactly(1).times.with(hash_including(:recurring_donor_id => @today_donor.id)).and_return(status: 'failed', message: 'Card declined')

    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    expect(@today_donor.reload).to have_attributes(next_charge_at: Date.tomorrow, last_fail_reason: 'Card declined', consecutive_fail_count: 1)
  end

  it "Shouldn't retry a failed donation the same day" do 
    expect_any_instance_of(StripeProcessor).to receive(:process).exactly(1).times.with(hash_including(:recurring_donor_id => @today_donor.id)).and_return(status: 'failed', message: 'Card declined')

    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }   
  end

  it "Should cancel the donation after 3 failures" do
    StripeProcessor.any_instance.stub(:process) { { status: 'failed', message: 'Card declined' } } 
    
    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    travel 1.day do
      perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    end
    travel 2.days do 
      StripeProcessor.any_instance.stub(:process) { { status: 'failed', message: 'Card expired' } } 
      perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
    end
    expect(@today_donor.reload).to have_attributes(next_charge_at: nil, last_fail_reason: 'Card expired', consecutive_fail_count: 3)
    expect(@today_donor.reload.ended_at).not_to be nil

  end

  it "Shouldn't try an ended_donation" do 
    @today_donor.update_attributes(ended_at: Time.now)
    expect_any_instance_of(StripeProcessor).not_to receive(:process).with(hash_including(:recurring_donor_id => @today_donor.id))

    perform_enqueued_jobs { ProcessRecurringDonorsJob.perform_later }
  end
end