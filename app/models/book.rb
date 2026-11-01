class Book < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error
  has_many :users, through: :borrowings

  validates :serial_number, presence: true, uniqueness: true, format: { with: /\A\d{6}\z/ }
  validates :title, presence: true
  validates :author, presence: true
end
