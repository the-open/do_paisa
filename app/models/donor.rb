class Donor < ApplicationRecord
  validates_presence_of :processor_id
  has_many :transactions
  belongs_to :processor
end
