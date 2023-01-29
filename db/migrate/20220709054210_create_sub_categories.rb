class CreateSubCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.timestamps null: false
      t.belongs_to :category, index: true
    end
  end
end
