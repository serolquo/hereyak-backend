class CreateAddressTos < ActiveRecord::Migration
  def change
    create_table :address_tos do |t|
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end
  end
end
