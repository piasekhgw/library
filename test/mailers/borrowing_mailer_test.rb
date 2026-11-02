require "test_helper"

class BorrowingMailerTest < ActionMailer::TestCase
  setup do
    @borrowing = borrowings(:active)
    @borrowing.update!(borrowed_at: Time.zone.local(2026, 10, 5, 12))
  end

  test "due_soon tells the reader when the book is due" do
    mail = BorrowingMailer.due_soon(@borrowing)

    assert_equal [users(:alice).email], mail.to
    assert_equal "Reminder: return \"Dune\" by 2026-11-04", mail.subject
    assert_includes mail.body.to_s, "Hello Alice Reader,"
    assert_includes mail.body.to_s, "\"Dune\" by Frank Herbert is due back on 2026-11-04"
  end

  test "due_today tells the reader to return the book today" do
    mail = BorrowingMailer.due_today(@borrowing)

    assert_equal [users(:alice).email], mail.to
    assert_equal "Due today: please return \"Dune\"", mail.subject
    assert_includes mail.body.to_s, "is due back today (2026-11-04)"
  end
end
