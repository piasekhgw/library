require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    book = Book.new(serial_number: "400001", title: "Persuasion", author: "Jane Austen")

    assert book.valid?
  end

  test "requires title and author" do
    book = Book.new(serial_number: "400001", title: nil, author: nil)

    assert_not book.valid?
    assert book.errors.of_kind?(:title, :blank)
    assert book.errors.of_kind?(:author, :blank)
  end

  test "serial_number must be exactly 6 digits" do
    ["12345", "1234567", "12345a", ""].each do |value|
      book = Book.new(serial_number: value, title: "Persuasion", author: "Jane Austen")

      assert_not book.valid?, "#{value.inspect} should be invalid"
    end
  end

  test "serial_number must be unique" do
    book = Book.new(serial_number: books(:dune).serial_number, title: "Persuasion", author: "Jane Austen")

    assert_not book.valid?
    assert book.errors.of_kind?(:serial_number, :taken)
  end

  test "has many users through borrowings" do
    assert_includes books(:dune).users, users(:alice)
  end

  test "cannot be destroyed while having borrowings" do
    assert_not books(:dune).destroy
    assert Book.exists?(books(:dune).id)
  end
end
