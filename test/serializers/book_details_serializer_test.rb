require "test_helper"

class BookDetailsSerializerTest < ActiveSupport::TestCase
  test "includes borrowing history with reader data, newest first" do
    Borrowing.create!(user: users(:alice), book: books(:emma))

    json = BookDetailsSerializer.new(books(:emma)).as_json

    assert_equal ["100001", "100002"], json["borrowings"].map { |borrowing| borrowing["reader"]["card_number"] }
    assert_equal %w[id borrowed_at returned_at reader], json["borrowings"].first.keys
    assert_equal %w[id card_number full_name email], json["borrowings"].first["reader"].keys
  end
end
