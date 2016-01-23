class CreateTagNames < ActiveRecord::Migration
  def change
    create_table :tag_names do |t|
      t.string :name

      t.timestamps
    end
  end
end
