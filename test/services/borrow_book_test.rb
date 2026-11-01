require "test_helper"

class BorrowBookTest < ActiveSupport::TestCase
  test "creates a borrowing for the reader with the given card number" do
    book = books(:emma)

    borrowing = assert_difference("Borrowing.count", 1) do
      BorrowBook.call(book, users(:alice).card_number)
    end

    assert_equal users(:alice), borrowing.user
    assert_equal book, borrowing.book
    assert book.reload.borrowed?
  end

  test "raises when the book is already borrowed" do
    assert_no_difference "Borrowing.count" do
      assert_raises(BorrowBook::AlreadyBorrowed) { BorrowBook.call(books(:dune), users(:bob).card_number) }
    end
  end

  test "raises when the card number is unknown" do
    assert_no_difference "Borrowing.count" do
      assert_raises(BorrowBook::ReaderNotFound) { BorrowBook.call(books(:emma), "999999") }
    end
  end

  test "raises when the book is soft deleted" do
    assert_no_difference "Borrowing.count" do
      assert_raises(ActiveRecord::RecordNotFound) { BorrowBook.call(books(:archived), users(:bob).card_number) }
    end
  end

  test "raises AlreadyBorrowed instead of relying on a stale association cache" do
    stale_book = Book.find(books(:emma).id)
    # Warm the association cache so the book looks available.
    stale_book.active_borrowing
    Borrowing.create!(user: users(:alice), book: books(:emma))

    assert_no_difference "Borrowing.count" do
      assert_raises(BorrowBook::AlreadyBorrowed) { BorrowBook.call(stale_book, users(:bob).card_number) }
    end
  end
end
