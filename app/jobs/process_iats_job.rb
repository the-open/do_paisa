require 'sidekiq-scheduler'

class ProcessIatsJob < ApplicationJob
  queue_as :default

  def perform
    processor = IatsProcessor.find(ENV['IATS_UUID'])
    processor.update_transactions_status(Date.yesterday)
  end
end
