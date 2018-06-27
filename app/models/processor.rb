class Processor < ApplicationRecord
  has_many :donors
  has_many :processor_email_templates
  has_many :outgoing_webhooks
  
  def add_recurring_donor(donor, amount, date = nil)
    RecurringDonor.create!(
      donor: donor,
      processor: self,
      amount: amount,
      last_charged_at: date ? nil : Date.today,
      next_charge_at: date || Date.today + 1.month
    )
  end
end
