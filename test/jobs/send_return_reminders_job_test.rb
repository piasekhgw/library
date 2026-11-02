require "test_helper"

class SendReturnRemindersJobTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @today = Date.new(2026, 11, 1)
    @borrowing = borrowings(:active)
  end

  test "sends a reminder 3 days before the due date" do
    borrow_on(@today - 27)

    assert_enqueued_email_with BorrowingMailer, :due_soon, args: [@borrowing] do
      SendReturnRemindersJob.perform_now(@today)
    end
    assert_enqueued_emails 1
  end

  test "sends a reminder on the due date" do
    borrow_on(@today - 30)

    assert_enqueued_email_with BorrowingMailer, :due_today, args: [@borrowing] do
      SendReturnRemindersJob.perform_now(@today)
    end
    assert_enqueued_emails 1
  end

  test "sends nothing on other days" do
    [@today - 26, @today - 28, @today - 29, @today - 31].each do |date|
      borrow_on(date)

      assert_no_enqueued_emails { SendReturnRemindersJob.perform_now(@today) }
    end
  end

  test "skips returned borrowings" do
    borrowings(:returned).update!(borrowed_at: (@today - 30).in_time_zone.change(hour: 9))
    @borrowing.update!(borrowed_at: @today.in_time_zone)

    assert_no_enqueued_emails { SendReturnRemindersJob.perform_now(@today) }
  end

  test "marks the due soon reminder as sent and does not send it twice" do
    borrow_on(@today - 27)

    assert_enqueued_emails(1) { SendReturnRemindersJob.perform_now(@today) }
    assert_not_nil @borrowing.reload.due_soon_reminder_sent_at
    assert_nil @borrowing.due_today_reminder_sent_at

    assert_no_enqueued_emails { SendReturnRemindersJob.perform_now(@today) }
  end

  test "marks the due today reminder as sent and does not send it twice" do
    borrow_on(@today - 30)

    assert_enqueued_emails(1) { SendReturnRemindersJob.perform_now(@today) }
    assert_not_nil @borrowing.reload.due_today_reminder_sent_at
    assert_nil @borrowing.due_soon_reminder_sent_at

    assert_no_enqueued_emails { SendReturnRemindersJob.perform_now(@today) }
  end

  test "sends the due today reminder even after the due soon reminder was sent" do
    borrow_on(@today - 27)
    SendReturnRemindersJob.perform_now(@today)

    assert_enqueued_email_with BorrowingMailer, :due_today, args: [@borrowing] do
      SendReturnRemindersJob.perform_now(@today + Borrowing::DUE_SOON_REMINDER_DAYS_BEFORE)
    end
  end

  private

  def borrow_on(date)
    @borrowing.update!(borrowed_at: date.in_time_zone.change(hour: 12))
  end
end
