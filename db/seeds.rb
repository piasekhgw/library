return unless Rails.env.development?

anna, jan, ewa = [
  { card_number: "100001", full_name: "Anna Kowalska", email: "anna.kowalska@example.com" },
  { card_number: "100002", full_name: "Jan Nowak", email: "jan.nowak@example.com" },
  { card_number: "100003", full_name: "Ewa Wiśniewska", email: "ewa.wisniewska@example.com" }
].map { |attributes| User.find_or_create_by!(attributes) }

books = [
  { id: 1, serial_number: "200001", title: "Nineteen Eighty-Four", author: "George Orwell" },
  { id: 2, serial_number: "200002", title: "Pride and Prejudice", author: "Jane Austen" },
  { id: 3, serial_number: "200003", title: "Dune", author: "Frank Herbert" },
  { id: 4, serial_number: "200004", title: "The Hobbit", author: "J.R.R. Tolkien" },
  { id: 5, serial_number: "200005", title: "Moby-Dick", author: "Herman Melville" },
  { id: 6, serial_number: "200006", title: "Frankenstein", author: "Mary Shelley" }
].map do |attributes|
  Book.find_or_initialize_by(id: attributes[:id]).tap { |book| book.update!(attributes.merge(deleted_at: nil)) }
end

# Books have fixed ids, so move the sequence past them or the first POST /api/books would collide.
Book.connection.reset_pk_sequence!(Book.table_name)

nineteen_eighty_four, pride, dune, hobbit = books

# Books 200005 and 200006 stay available. The others cover different borrowing states.
# Borrowings of the seeded books are recreated on every run: dates are relative to now,
# reminder flags are cleared and any borrowing made through the API is discarded.
Borrowing.where(book: books).delete_all

[
  { user: anna, book: nineteen_eighty_four, borrowed_at: 5.days.ago },
  { user: jan, book: pride, borrowed_at: (Borrowing::LOAN_DAYS - Borrowing::DUE_SOON_REMINDER_DAYS_BEFORE).days.ago },
  { user: ewa, book: dune, borrowed_at: Borrowing::LOAN_DAYS.days.ago },
  { user: anna, book: hobbit, borrowed_at: 40.days.ago, returned_at: 20.days.ago }
].each { |attributes| Borrowing.create!(attributes) }
