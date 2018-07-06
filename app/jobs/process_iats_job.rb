require 'sidekiq-scheduler'

class ProcessIatsJob < ApplicationJob
  queue_as :default

  def perform
    processor = IatsProcessor.find(ENV['IATS_UUID'])

    30.days.ago.to_date.upto(Date.today) do |date|
      processor.update_transactions_status(date.to_time)
    end
  end
end
