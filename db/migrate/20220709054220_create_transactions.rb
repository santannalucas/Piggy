class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.float :amount, default: 0
      t.float :rated_amount, default: 0
      t.timestamps null: false
      t.string :description
      t.boolean :transfer
      t.belongs_to :bank_account, index: true
      t.belongs_to :account, index: true
      t.belongs_to :sub_category, index: true
      t.belongs_to :transaction_type, index: true
    end
  end
end
