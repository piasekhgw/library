class BooksController < ApplicationController
  before_action :require_card_number_key, only: :update

  rescue_from BorrowBook::AlreadyBorrowed do
    render_conflict("Book is already borrowed")
  end

  rescue_from BorrowBook::ReaderNotFound do
    render json: { errors: { card_number: ["not found"] } }, status: :unprocessable_content
  end

  rescue_from ReturnBook::NotBorrowed do
    render_conflict("Book is not borrowed")
  end

  def index
    books = Book.not_deleted.includes(:active_borrowing).order(:title)

    render json: books.map { |book| BookSerializer.new(book) }
  end

  def show
    book = Book.not_deleted.find(params[:id])

    render json: BookDetailsSerializer.new(book)
  end

  def create
    book = Book.new(book_params)

    if book.save
      render json: BookSerializer.new(book), status: :created, location: book
    else
      render json: { errors: book.errors }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    # Two concurrent requests can both pass the uniqueness validation; the unique index rejects the second one.
    book.errors.add(:serial_number, :taken)
    render json: { errors: book.errors }, status: :unprocessable_content
  end

  def update
    book = Book.not_deleted.find(params[:id])

    if params[:card_number].nil?
      ReturnBook.call(book)
    else
      BorrowBook.call(book, params[:card_number])
    end

    render json: BookSerializer.new(book.reload)
  end

  def destroy
    book = Book.not_deleted.find(params[:id])

    # Lock the row so a concurrent borrow cannot slip in between the check and the delete.
    book.with_lock do
      if book.borrowed?
        render_conflict("Book is currently borrowed")
      else
        book.update!(deleted_at: Time.current)
        head :no_content
      end
    end
  end

  private

  def require_card_number_key
    raise ActionController::ParameterMissing, :card_number unless params.key?(:card_number)
  end

  def book_params
    params.expect(book: %i[serial_number title author])
  end

  def render_conflict(message)
    render json: { error: message }, status: :conflict
  end
end
