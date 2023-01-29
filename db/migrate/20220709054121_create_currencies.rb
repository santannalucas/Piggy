class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :code
      t.float :rate
      t.timestamps null: false
      t.belongs_to :user, index: true
    end
  end
end
