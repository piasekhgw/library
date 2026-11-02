class BorrowingMailer < ApplicationMailer
  def due_soon(borrowing)
    remind(borrowing)
  end

  def due_today(borrowing)
    remind(borrowing)
  end

  private

  def remind(borrowing)
    @user = borrowing.user
    @book = borrowing.book
    @due_on = borrowing.borrowed_at.to_date + Borrowing::LOAN_DAYS

    mail to: @user.email,
         subject: default_i18n_subject(title: @book.title, due_on: I18n.l(@due_on))
  end
end
