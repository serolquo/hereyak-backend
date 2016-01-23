class RemoveLengthLimitForPost < ActiveRecord::Migration
  def up
    change_column :posts, :content, :string, :limit => 1280
  end

  def down
    change_column :posts, :content, :string, :limit => 255
  end
end
