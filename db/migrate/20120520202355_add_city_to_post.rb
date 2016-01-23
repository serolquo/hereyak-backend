class AddCityToPost < ActiveRecord::Migration
  def change
    add_column :posts, :city, :string
    add_column :posts, :postal_code, :string
    add_column :posts, :country, :string
  end
end
