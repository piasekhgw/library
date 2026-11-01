class BorrowingSerializer
  include ActiveModel::Serializers::JSON

  delegate :id, :borrowed_at, :returned_at, to: :@borrowing

  def initialize(borrowing)
    @borrowing = borrowing
  end

  def attributes
    { "id" => nil, "borrowed_at" => nil, "returned_at" => nil, "reader" => nil }
  end

  def reader
    UserSerializer.new(@borrowing.user)
  end
end
