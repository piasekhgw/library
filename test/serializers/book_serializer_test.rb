require "test_helper"

class BookSerializerTest < ActiveSupport::TestCase
  test "serializes only public book attributes" do
    json = BookSerializer.new(books(:emma)).as_json

    assert_equal %w[id serial_number title author status current_borrowing], json.keys
    assert_equal "Emma", json["title"]
  end

  test "current_borrowing has the borrow date and reader data when the book is borrowed" do
    current = BookSerializer.new(books(:dune)).as_json["current_borrowing"]

    assert_equal %w[id borrowed_at returned_at reader], current.keys
    assert_nil current["returned_at"]
    assert_equal %w[id card_number full_name email], current["reader"].keys
  end

  test "current_borrowing is nil when the book is available" do
    assert_nil BookSerializer.new(books(:emma)).as_json["current_borrowing"]
  end

  test "status is borrowed when the book has an active borrowing" do
    assert_equal "borrowed", BookSerializer.new(books(:dune)).as_json["status"]
  end

  test "status is available when the book has no active borrowing" do
    assert_equal "available", BookSerializer.new(books(:emma)).as_json["status"]
  end
end
