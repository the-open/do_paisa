class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :recurring_donor, optional: true
  belongs_to :donor

  validates_presence_of :amount, :external_id, :status, :processor_id
end
