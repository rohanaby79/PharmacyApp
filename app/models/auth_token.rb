class AuthToken < ApplicationRecord
    belongs_to :doctor
  
    validates :token, presence: true, uniqueness: true
    validates :expires_at, presence: true
  
    def valid_token?
      expires_at > Time.current
    end
  
    def self.generate_token
      SecureRandom.hex(32)
    end
  end