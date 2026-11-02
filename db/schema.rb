# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_01_223000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "serial_number", limit: 6, null: false
    t.string "title", null: false
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["serial_number"], name: "index_books_on_serial_number", unique: true
    t.check_constraint "serial_number::text ~ '^[0-9]{6}$'::text", name: "books_serial_number_format"
  end

  create_table "borrowings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.datetime "borrowed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "due_soon_reminder_sent_at"
    t.datetime "due_today_reminder_sent_at"
    t.index ["book_id", "borrowed_at"], name: "index_borrowings_on_book_id_and_borrowed_at"
    t.index ["book_id"], name: "index_borrowings_on_book_id_active", unique: true, where: "(returned_at IS NULL)"
    t.index ["user_id"], name: "index_borrowings_on_user_id"
    t.check_constraint "returned_at IS NULL OR returned_at >= borrowed_at", name: "borrowings_returned_after_borrowed"
  end

  create_table "users", force: :cascade do |t|
    t.string "card_number", limit: 6, null: false
    t.string "full_name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_number"], name: "index_users_on_card_number", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "card_number::text ~ '^[0-9]{6}$'::text", name: "users_card_number_format"
  end

  add_foreign_key "borrowings", "books"
  add_foreign_key "borrowings", "users"
end
