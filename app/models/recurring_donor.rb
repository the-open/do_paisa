class RecurringDonor < ApplicationRecord
  has_many :transactions
  belongs_to :processor
  belongs_to :donor

  validates_presence_of :amount, :donor_id, :processor_id

  def charge
    process_params = {
      token: donor.id,
      amount: amount,
      recurring_donor_id: id
    }

    processor.process(process_params)
  end
end
