class RecurringDonor < ApplicationRecord
  has_many :transactions
  belongs_to :processor
  belongs_to :donor

  validates_presence_of :amount, :donor_id, :processor_id

  def charge
    process_params = {
      token: donor.token,
      amount: amount,
      recurring_donor_id: id,
      idempotency_key: Digest::MD5.hexdigest("#{donor_id}:#{Date.today.month}:#{consecutive_fail_count}")
    }

    processor.process(process_params)
  end
end
