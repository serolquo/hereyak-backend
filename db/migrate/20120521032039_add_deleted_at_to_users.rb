class AddDeletedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted_at, :datetime
    add_column :users, :active, :integer, :default => 1
  end
end
