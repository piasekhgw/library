require "test_helper"

class ReturnBookTest < ActiveSupport::TestCase
  test "sets returned_at on the active borrowing" do
    borrowing = ReturnBook.call(books(:dune))

    assert_equal borrowings(:active), borrowing
    assert_not_nil borrowing.reload.returned_at
    assert_not books(:dune).reload.borrowed?
  end

  test "raises when the book is not borrowed" do
    assert_raises(ReturnBook::NotBorrowed) { ReturnBook.call(books(:emma)) }
  end
end
