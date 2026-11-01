class AddDeletedAtToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :deleted_at, :datetime
  end
end
