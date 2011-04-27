class CreateFormTests < ActiveRecord::Migration
  def self.up
    create_table :form_tests do |t|
      t.boolean :checkbox
      t.string :hidden
      t.string :collection_select
      t.string :select
      t.string :grouped_collection_select
      t.decimal :amount
      t.string :currency

      t.timestamps
    end
  end

  def self.down
    drop_table :form_tests
  end
end
