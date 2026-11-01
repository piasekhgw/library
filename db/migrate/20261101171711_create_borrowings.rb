class CreateBorrowings < ActiveRecord::Migration[8.1]
  def change
    create_table :borrowings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true, index: false
      t.datetime :borrowed_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :returned_at

      t.timestamps

      t.index [:book_id, :borrowed_at]
      t.index :book_id, unique: true, where: "returned_at IS NULL",
              name: "index_borrowings_on_book_id_active"
      t.check_constraint "returned_at IS NULL OR returned_at >= borrowed_at",
                         name: "borrowings_returned_after_borrowed"
    end
  end
end
