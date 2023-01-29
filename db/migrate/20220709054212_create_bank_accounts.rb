class CreateBankAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.string :number
      t.text :description
      t.boolean :active
      t.integer :account_type
      t.timestamps null: false
      t.boolean :dashboard
      t.belongs_to :currency, index: true
      t.belongs_to :user, index: true
    end
  end
end
