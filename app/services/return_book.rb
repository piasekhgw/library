class ReturnBook
  class NotBorrowed < StandardError; end

  def self.call(book)
    new(book).call
  end

  def initialize(book)
    @book = book
  end

  def call
    @book.with_lock do
      borrowing = @book.active_borrowing
      raise NotBorrowed if borrowing.nil?

      borrowing.update!(returned_at: Time.current)
      borrowing
    end
  end
end
