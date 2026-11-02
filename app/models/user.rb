class User < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error
  has_many :books, through: :borrowings

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :card_number, presence: true, uniqueness: true, format: { with: /\A\d{6}\z/ }
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
