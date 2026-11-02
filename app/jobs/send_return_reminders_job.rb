class SendReturnRemindersJob < ApplicationJob
  queue_as :default

  def perform(today = Time.zone.today)
    each_unsent(today + Borrowing::DUE_SOON_REMINDER_DAYS_BEFORE, :due_soon_reminder_sent_at) do |borrowing|
      BorrowingMailer.due_soon(borrowing).deliver_later
    end

    each_unsent(today, :due_today_reminder_sent_at) do |borrowing|
      BorrowingMailer.due_today(borrowing).deliver_later
    end
  end

  private

  def each_unsent(due_on, column)
    Borrowing.active.due_on(due_on).where(column => nil).includes(:user, :book).find_each do |borrowing|
      yield borrowing
      borrowing.update!(column => Time.current)
    end
  end
end
