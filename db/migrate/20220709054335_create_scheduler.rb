class CreateScheduler < ActiveRecord::Migration[5.2]
  def change

    create_table :schedulers do |t|
      t.belongs_to :scheduler_type
      t.belongs_to :bank_account
      t.belongs_to :account
      t.belongs_to :user
      t.belongs_to :scheduler_period
      t.belongs_to :sub_category
      t.string :description
      t.integer :split
      t.float :amount
      t.integer :transfer_bank_id
      t.integer :transaction_type_id
      t.datetime :last_payment
      t.timestamps null: false
    end

    create_table :scheduler_types do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :scheduler_periods do |t|
      t.string :name
      t.integer :days
      t.integer :months
    end

    create_table :scheduler_items do |t|
      t.float :amount
      t.belongs_to :transaction
      t.belongs_to :scheduler
      t.timestamps null: false
    end

  end
end