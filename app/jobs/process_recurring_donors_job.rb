require 'sidekiq-scheduler'

class ProcessRecurringDonorsJob < ApplicationJob
  queue_as :default

  def perform
    donors_to_process = RecurringDonor.where(next_charge_at: Date.today).where("ended_at is null")
    donors_to_process.each do |recurring_donor|
      response = recurring_donor.charge
      recurring_donor.update!(next_charge_at: Date.today + 1.month)
    end
  end
end
