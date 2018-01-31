class Processor < ApplicationRecord
  has_many :donors
  
  def add_recurring_donor(donor, amount)
    RecurringDonor.create!(
      donor: donor,
      processor: self,
      amount: amount,
      last_charged_at: Date.today,
      next_charge_at: Date.today + 1.month
    )
  end
end
