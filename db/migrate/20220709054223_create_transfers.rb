class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.integer :from_id
      t.integer :to_id
      t.float   :rate
      t.timestamps null: false
      t.string :description
    end
  end
end
