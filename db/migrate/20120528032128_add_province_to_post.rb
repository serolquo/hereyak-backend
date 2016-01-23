class AddProvinceToPost < ActiveRecord::Migration
  def change
    add_column :posts, :province, :string
  end
end
