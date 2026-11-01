class BookSerializer
  include ActiveModel::Serializers::JSON

  delegate :id, :serial_number, :title, :author, to: :@book

  def initialize(book)
    @book = book
  end

  def attributes
    { "id" => nil, "serial_number" => nil, "title" => nil, "author" => nil, "status" => nil }
  end

  def status
    @book.borrowed? ? "borrowed" : "available"
  end
end
