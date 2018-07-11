require 'sidekiq-scheduler'

class ProcessIatsJob < ApplicationJob
  queue_as :default

  def perform
    IatsProcessor.all.each do |processor|
      30.days.ago.to_date.upto(Date.today) do |date|
        processor.update_transactions_status(date.to_time)
      end
    end
  end
end
