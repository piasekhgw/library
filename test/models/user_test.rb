require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with valid attributes" do
    user = User.new(card_number: "300001", full_name: "Carol Reader", email: "carol@example.com")

    assert user.valid?
  end

  test "requires full_name and email" do
    user = User.new(card_number: "300001", full_name: nil, email: nil)

    assert_not user.valid?
    assert user.errors.of_kind?(:full_name, :blank)
    assert user.errors.of_kind?(:email, :blank)
  end

  test "card_number must be exactly 6 digits" do
    ["12345", "1234567", "12345a", ""].each do |value|
      user = User.new(card_number: value, full_name: "Carol Reader", email: "carol@example.com")

      assert_not user.valid?, "#{value.inspect} should be invalid"
    end
  end

  test "card_number must be unique" do
    user = User.new(card_number: users(:alice).card_number, full_name: "Carol Reader", email: "carol@example.com")

    assert_not user.valid?
    assert user.errors.of_kind?(:card_number, :taken)
  end

  test "email must be unique and well formed" do
    duplicate = User.new(card_number: "300001", full_name: "Carol Reader", email: users(:alice).email)
    malformed = User.new(card_number: "300001", full_name: "Carol Reader", email: "not-an-email")

    assert_not duplicate.valid?
    assert_not malformed.valid?
  end

  test "has many borrowed books through borrowings" do
    assert_includes users(:alice).books, books(:dune)
  end

  test "cannot be destroyed while having borrowings" do
    assert_not users(:alice).destroy
    assert User.exists?(users(:alice).id)
  end
end
