require "test_helper"

class BorrowingTest < ActiveSupport::TestCase
  test "requires user and book" do
    borrowing = Borrowing.new

    assert_not borrowing.valid?
    assert borrowing.errors.of_kind?(:user, :blank)
    assert borrowing.errors.of_kind?(:book, :blank)
  end

  test "borrowed_at defaults to current time set by the database" do
    borrowing = Borrowing.create!(user: users(:bob), book: books(:emma))

    assert_in_delta Time.current, borrowing.reload.borrowed_at, 5.seconds
    assert borrowing.active?
  end

  test "active scope returns only borrowings without returned_at" do
    assert_includes Borrowing.active, borrowings(:active)
    assert_not_includes Borrowing.active, borrowings(:returned)
  end

  test "due_on scope returns borrowings due back on the given day" do
    borrowing = borrowings(:active)
    borrowing.update!(borrowed_at: Time.zone.local(2026, 10, 5, 23, 59))

    assert_includes Borrowing.due_on(Date.new(2026, 11, 4)), borrowing
    assert_not_includes Borrowing.due_on(Date.new(2026, 11, 3)), borrowing
    assert_not_includes Borrowing.due_on(Date.new(2026, 11, 5)), borrowing
  end

  test "book cannot be actively borrowed twice" do
    borrowing = Borrowing.new(user: users(:bob), book: books(:dune))

    assert_not borrowing.valid?
    assert borrowing.errors.of_kind?(:book_id, :taken)
  end

  test "book can be borrowed again after it was returned" do
    borrowing = Borrowing.new(user: users(:alice), book: books(:emma))

    assert borrowing.valid?
  end

  test "returned borrowing stays valid when the book is borrowed again" do
    Borrowing.create!(user: users(:alice), book: books(:emma))
    returned = borrowings(:returned)
    returned.returned_at += 1.day

    assert returned.valid?
  end

  test "returned_at cannot be before borrowed_at" do
    borrowing = borrowings(:active)
    borrowing.returned_at = borrowing.borrowed_at - 1.day

    assert_not borrowing.valid?
    assert_includes borrowing.errors[:returned_at], "cannot be before borrowed_at"
  end

  test "database rejects a second active borrowing of the same book" do
    borrowing = Borrowing.new(user: users(:bob), book: books(:dune))

    assert_raises(ActiveRecord::RecordNotUnique) { borrowing.save!(validate: false) }
  end
end
