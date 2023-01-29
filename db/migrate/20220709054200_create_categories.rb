class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :category_type
      t.timestamps null: false
      t.belongs_to :user
    end
  end
end
