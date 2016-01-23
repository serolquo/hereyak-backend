class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :content
      t.integer :user_id
      t.string :lat
      t.string :lon
      t.datetime :post_date
      t.integer :reply_to_post

      t.timestamps
    end
  end
end
