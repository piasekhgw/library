class Book < ApplicationRecord
  has_many :borrowings, dependent: :restrict_with_error
  has_one :active_borrowing, -> { active }, class_name: "Borrowing"
  has_many :users, through: :borrowings

  scope :not_deleted, -> { where(deleted_at: nil) }

  validates :serial_number, presence: true, uniqueness: true, format: { with: /\A\d{6}\z/ }
  validates :title, presence: true
  validates :author, presence: true

  def borrowed?
    active_borrowing.present?
  end
end
