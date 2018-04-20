require 'sidekiq-scheduler'

class ProcessIatsJob < ApplicationJob
  queue_as :default

  def perform
    processor = IatsProcessor.find_by(type: "IatsProcessor")
    processor.update_transactions_status(Date.today)
  end
end
