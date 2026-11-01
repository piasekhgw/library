class BorrowBook
  class AlreadyBorrowed < StandardError; end
  class ReaderNotFound < StandardError; end

  def self.call(book, card_number)
    new(book, card_number).call
  end

  def initialize(book, card_number)
    @book = book
    @card_number = card_number
  end

  def call
    # Row lock makes concurrent borrow/return/delete of the same book run one at a
    # time, so the borrowed? check and the insert below cannot interleave with another request.
    @book.with_lock do
      raise ActiveRecord::RecordNotFound if @book.deleted_at?
      raise AlreadyBorrowed if @book.borrowed?

      user = User.find_by(card_number: @card_number)
      raise ReaderNotFound if user.nil?

      @book.borrowings.create!(user: user)
    end
  end
end
