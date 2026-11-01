class BookDetailsSerializer < BookSerializer
  def attributes
    super.merge("borrowings" => nil)
  end

  def borrowings
    @book.borrowings.includes(:user).order(borrowed_at: :desc).map do |borrowing|
      BorrowingSerializer.new(borrowing)
    end
  end
end
