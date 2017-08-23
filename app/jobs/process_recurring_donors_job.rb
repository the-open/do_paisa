class ProcessRecurringDonorsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    donors_to_process = RecurringDonor.where(next_charge_at: Date.today)
    donors_to_process.each do |recurring_donor|
      response = recurring_donor.charge
      if response[:status].eql?('succeeded')
        recurring_donor.update_attributes!(
          last_charged_at: Date.today,
          next_charge_at: Date.today + 1.month
        )
      end
    end
  end
end
