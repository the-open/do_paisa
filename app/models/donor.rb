class Donor < ApplicationRecord
  validates_presence_of :processor_id
  has_many :transactions
  belongs_to :processor
  has_one :recurring_donor
  
  ransacker :email do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:metadata], Arel::Nodes.build_quoted('email'))
  end
  
  ransacker :name do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:metadata], Arel::Nodes.build_quoted('name'))
  end
end
