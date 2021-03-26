class UploadPODonationsWorker
  include Sidekiq::Worker

  def perform(csv_string)
    CSV.parse(File.read(csv_string), { headers: true }).each do |row|
      UploadPODonationsRowWorker.perform_async(row.to_h.to_json)
    end
  end
end