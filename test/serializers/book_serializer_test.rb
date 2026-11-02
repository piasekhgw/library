require "test_helper"

class BookSerializerTest < ActiveSupport::TestCase
  test "serializes only public book attributes" do
    json = BookSerializer.new(books(:emma)).as_json

    assert_equal %w[id serial_number title author status], json.keys
    assert_equal "Emma", json["title"]
  end

  test "status is borrowed when the book has an active borrowing" do
    assert_equal "borrowed", BookSerializer.new(books(:dune)).as_json["status"]
  end

  test "status is available when the book has no active borrowing" do
    assert_equal "available", BookSerializer.new(books(:emma)).as_json["status"]
  end
end
