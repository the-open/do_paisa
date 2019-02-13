class Donor < ApplicationRecord
  validates_presence_of :processor_id
  has_many :transactions
  belongs_to :processor
  has_one :recurring_donor
  
  ransacker :email do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:metadata], Arel::Nodes.build_quoted('email'))
  end
  
  ransacker :first_name do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:metadata], Arel::Nodes.build_quoted('first_name'))
  end

  ransacker :last_name do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:metadata], Arel::Nodes.build_quoted('last_name'))
  end

  ransacker :external_id do |parent|
    parent.table[:external_id]
  end
end
