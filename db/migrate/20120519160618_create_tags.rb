class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :post_id
      t.integer :tag_name_id

      t.timestamps
    end
  end
end
