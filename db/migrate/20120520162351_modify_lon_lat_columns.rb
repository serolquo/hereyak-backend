class ModifyLonLatColumns < ActiveRecord::Migration
  def up
    remove_columns :posts, :lat, :lon
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float
  end

  def down
    remove_columns :posts, :latitude, :longitude
    add_column :posts, :lat, :string
    add_column :posts, :lon, :string
  end
end
