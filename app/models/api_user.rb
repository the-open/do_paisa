class ApiUser < ApplicationRecord
  after_create :generate_key

  def generate_key
    self.key = SecureRandom.urlsafe_base64(30)
    save!
  end
end
