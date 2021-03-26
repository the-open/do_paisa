class UploadPODonationsRowWorker
  include Sidekiq::Worker

  def perform(row_json)
    begin
      processor = PODonationDataProcessor.new
      processor.process(JSON.parse(row_json))
    rescue => e
      raise e
    end
  end
end