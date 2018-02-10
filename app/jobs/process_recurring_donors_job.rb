require 'sidekiq-scheduler'

class ProcessRecurringDonorsJob < ApplicationJob
  queue_as :default

  def perform
    donors_to_process = RecurringDonor.where(next_charge_at: Date.today).where("ended_at is null")
    donors_to_process.each do |recurring_donor|
      response = recurring_donor.charge
      if response[:status] == 'success'
        recurring_donor.update_attributes!(
          last_charged_at: Date.today,
          next_charge_at: Date.today + 1.month,
          consecutive_fail_count: 0
        )
      elsif response[:status] == 'failed' 
        if recurring_donor.consecutive_fail_count < 2
          recurring_donor.update_attributes!(
            next_charge_at: Date.tomorrow,
            consecutive_fail_count: recurring_donor.consecutive_fail_count + 1,
            last_fail_reason: response[:message]
          )
        else
          recurring_donor.update_attributes!(
            next_charge_at: nil,
            ended_at: Time.now,
            consecutive_fail_count: recurring_donor.consecutive_fail_count + 1,
            last_fail_reason: response[:message]
          )
        end
      end
    end
  end
end
