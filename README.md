# Library

Rails API for a small library: books, readers and borrowings. Overdue handling is
done by a daily background job that sends return reminders by email.

## Quick start

Requires Docker only.

```sh
docker compose up
```

The app listens on <http://localhost:3000>. On every start the container prepares
the databases and loads development seeds:

| Readers (card numbers) | Books (`id`, serial number) | State |
|---|---|---|
| Anna Kowalska `100001` | `1` / `200001` Nineteen Eighty-Four | borrowed 5 days ago |
| Jan Nowak `100002` | `2` / `200002` Pride and Prejudice | due in 3 days (reminder "due soon") |
| Ewa Wiśniewska `100003` | `3` / `200003` Dune | due today (reminder "due today") |
| | `4` / `200004` The Hobbit | returned |
| | `5` / `200005` Moby-Dick, `6` / `200006` Frankenstein | available |

Seeds use fixed book ids (1-6) and recreate the borrowings of these books on every
start, so dates are always relative to "now" and the examples below always work.

## API

```sh
# list books (status: available / borrowed)
curl localhost:3000/books

# book details with borrowing history
curl localhost:3000/books/1

# create a book
curl -X POST localhost:3000/books \
  -H 'Content-Type: application/json' \
  -d '{"book": {"serial_number": "300001", "title": "Emma", "author": "Jane Austen"}}'

# borrow a book (id 5 is available) with a reader's card number
curl -X PATCH localhost:3000/books/5 \
  -H 'Content-Type: application/json' \
  -d '{"card_number": "100001"}'

# return it (card_number key present and null)
curl -X PATCH localhost:3000/books/5 \
  -H 'Content-Type: application/json' \
  -d '{"card_number": null}'

# delete a book (soft delete, not allowed while borrowed)
curl -X DELETE localhost:3000/books/6
```

Errors: `404` unknown book, `409` already borrowed / not borrowed / currently
borrowed, `422` validation errors or unknown card number.

## Return reminders

A Solid Queue job (`SendReturnRemindersJob`) runs daily at 08:00 UTC, embedded in
the web process, and emails readers whose book is due in 3 days and due today.
Each reminder is sent once per borrowing. To trigger it manually:

```sh
docker compose exec web bin/rails runner 'SendReturnRemindersJob.perform_now'
```

In development mails are written to `tmp/letter_opener` (open the HTML files in a
browser). Without Docker, `letter_opener` opens them in the browser directly.

## Tests

```sh
docker compose exec web bin/rails test
```
