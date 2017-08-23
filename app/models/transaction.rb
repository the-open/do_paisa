class Transaction < ApplicationRecord
  belongs_to :processor
  belongs_to :donor

  validates_presence_of :amount, :external_id, :status, :processor_id
end
