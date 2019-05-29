require 'sidekiq-scheduler'

class ProcessRecurringDonorsJob < ApplicationJob
  queue_as :default

  def perform
    donors_to_process = RecurringDonor.not_ended.next_charge_on_or_before_today
    donors_to_process.each(&:charge)
  end
end