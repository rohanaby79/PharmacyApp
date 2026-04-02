class Doctor < ApplicationRecord
    #（bcrypt）
    has_secure_password

    has_many :auth_tokens, dependent: :destroy

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :license_number, presence: true, uniqueness: true
    validates :active, inclusion: { in: [true, false] }
  
    def active?
      active == true
    end
  end