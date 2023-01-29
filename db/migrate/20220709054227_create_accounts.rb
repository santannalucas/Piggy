class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :description
      t.boolean :expenses
      t.boolean :deposits
      t.timestamps null: false
      t.belongs_to :user, index: true
    end
  end
end
