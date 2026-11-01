class UserSerializer
  include ActiveModel::Serializers::JSON

  delegate :id, :card_number, :full_name, :email, to: :@user

  def initialize(user)
    @user = user
  end

  def attributes
    { "id" => nil, "card_number" => nil, "full_name" => nil, "email" => nil }
  end
end
