class Donor < ApplicationRecord
  validates_presence_of :processor_id
  has_many :transactions
  belongs_to :processor
  has_one :recurring_donor

  scope :cc_expiry_dates, -> { where(id: RecurringDonor.where(processor_id: Processor.where(name: "Stripe"), ended_at: nil).pluck(:donor_id)) }

  def self.to_csv
    donor_cc_expiries = Donor.cc_expiry_dates
    attributes = %w{first_name last_name email phone address_line1 address_line2 city province postal_code cc_expiry_date last_charged_at}
    CSV.generate do |csv|
      csv << attributes
      donor_cc_expiries.each do |donor|
        csv << [donor.metadata['first_name'],
        donor.metadata['last_name'],
        donor.metadata['email'],
        donor.metadata['phone'],
        donor.metadata['address_line1'],
        donor.metadata['address_line2'],
        donor.metadata['address_city'],
        donor.metadata['address_state'],
        donor.metadata['address_zip'],
        Date.parse(JSON.parse(donor.data)['sources']['data'][0]['exp_month'].to_s + '/' + JSON.parse(donor.data)['sources']['data'][0]['exp_year'].to_s),
        donor.recurring_donor.last_charged_at
      ]
      end
    end
  end
  
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
