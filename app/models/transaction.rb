class Transaction < ApplicationRecord
  belongs_to :processor

  validates_presence_of :amount, :external_id, :status, :processor_id
end
