class DonorEmail < ApplicationRecord
  validates_presence_of :donor, :subject, :sender_email, :sender_name, :html
  belongs_to :donor
end
