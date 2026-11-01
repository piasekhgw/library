class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book

  scope :active, -> { where(returned_at: nil) }

  validates :book_id, uniqueness: { conditions: -> { active } }, if: :active?
  validate :returned_at_not_before_borrowed_at

  def active?
    returned_at.nil?
  end

  private

  def returned_at_not_before_borrowed_at
    return if returned_at.nil? || borrowed_at.nil?

    errors.add(:returned_at, "cannot be before borrowed_at") if returned_at < borrowed_at
  end
end
