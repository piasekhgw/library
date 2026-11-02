require "test_helper"
require "minitest/mock"

class Api::BooksControllerTest < ActionDispatch::IntegrationTest
  test "index lists books with their status and skips deleted books" do
    get api_books_url, as: :json

    assert_response :ok
    statuses = response.parsed_body.to_h { |book| [book["title"], book["status"]] }
    assert_equal({ "Dune" => "borrowed", "Emma" => "available" }, statuses)

    current = response.parsed_body.to_h { |book| [book["title"], book["current_borrowing"]] }
    assert_not_nil current["Dune"]["borrowed_at"]
    assert_not_nil current["Dune"]["reader"]["full_name"]
    assert_nil current["Emma"]
  end

  test "show returns the book with borrowing history and reader data, newest first" do
    Borrowing.create!(user: users(:alice), book: books(:emma))

    get api_book_url(books(:emma)), as: :json

    assert_response :ok
    body = response.parsed_body
    assert_equal "borrowed", body["status"]
    assert_equal ["100001", "100002"], body["borrowings"].map { |borrowing| borrowing["reader"]["card_number"] }
    assert_nil body["borrowings"].first["returned_at"]
    assert_not_nil body["borrowings"].last["returned_at"]
    assert_equal "Bob Reader", body["borrowings"].last["reader"]["full_name"]
  end

  test "show returns not found for a deleted book" do
    get api_book_url(books(:archived)), as: :json

    assert_response :not_found
  end

  test "create adds an available book" do
    assert_difference "Book.count", 1 do
      post api_books_url, params: { serial_number: "500001", title: "Persuasion", author: "Jane Austen" }, as: :json
    end

    assert_response :created
    assert_equal api_book_url(Book.find_by!(serial_number: "500001")), response.location
    assert_equal "available", response.parsed_body["status"]
    assert_equal "Persuasion", response.parsed_body["title"]
  end

  test "create returns validation errors" do
    assert_no_difference "Book.count" do
      post api_books_url, params: { serial_number: "123", title: "", author: "Jane Austen" }, as: :json
    end

    assert_response :unprocessable_content
    assert_includes response.parsed_body["errors"].keys, "serial_number"
    assert_includes response.parsed_body["errors"].keys, "title"
  end

  test "update with a card number borrows an available book for the reader" do
    book = books(:emma)

    assert_difference "Borrowing.count", 1 do
      patch api_book_url(book), params: { card_number: users(:alice).card_number }, as: :json
    end

    assert_response :ok
    assert_equal "borrowed", response.parsed_body["status"]
    assert_equal users(:alice), book.active_borrowing.user
  end

  test "update with a card number on a borrowed book returns conflict" do
    assert_no_difference "Borrowing.count" do
      patch api_book_url(books(:dune)), params: { card_number: users(:bob).card_number }, as: :json
    end

    assert_response :conflict
  end

  test "update with an unknown card number returns validation error" do
    assert_no_difference "Borrowing.count" do
      patch api_book_url(books(:emma)), params: { card_number: "999999" }, as: :json
    end

    assert_response :unprocessable_content
    assert_equal ["not found"], response.parsed_body["errors"]["card_number"]
  end

  test "update with a null card number marks the borrowed book as returned" do
    patch api_book_url(books(:dune)), params: { card_number: nil }, as: :json

    assert_response :ok
    assert_equal "available", response.parsed_body["status"]
    assert_not_nil borrowings(:active).reload.returned_at
  end

  test "update with a null card number on an available book returns conflict" do
    patch api_book_url(books(:emma)), params: { card_number: nil }, as: :json

    assert_response :conflict
  end

  test "update without card number returns bad request" do
    patch api_book_url(books(:emma)), params: {}, as: :json

    assert_response :bad_request
  end

  test "update returns not found for a deleted book" do
    patch api_book_url(books(:archived)), params: { card_number: users(:bob).card_number }, as: :json

    assert_response :not_found
  end

  test "create returns validation error when the unique index rejects a concurrent insert" do
    book = Book.new(serial_number: "500001", title: "Persuasion", author: "Jane Austen")
    book.define_singleton_method(:save) { |*| raise ActiveRecord::RecordNotUnique }

    Book.stub :new, book do
      post api_books_url, params: { serial_number: "500001", title: "Persuasion", author: "Jane Austen" }, as: :json
    end

    assert_response :unprocessable_content
    assert_equal ["has already been taken"], response.parsed_body["errors"]["serial_number"]
  end

  test "destroy soft deletes an available book and keeps its history" do
    book = books(:emma)

    delete api_book_url(book), as: :json

    assert_response :no_content
    assert_not_nil book.reload.deleted_at
    assert_not_includes Book.not_deleted, book
    assert_equal 1, book.borrowings.count
  end

  test "destroy refuses to delete a borrowed book" do
    delete api_book_url(books(:dune)), as: :json

    assert_response :conflict
    assert_nil books(:dune).reload.deleted_at
  end
end
