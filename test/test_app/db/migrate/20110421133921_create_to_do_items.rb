class CreateToDoItems < ActiveRecord::Migration
  def self.up
    create_table :to_do_items do |t|
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :to_do_items
  end
end
