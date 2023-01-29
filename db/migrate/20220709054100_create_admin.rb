class CreateAdmin < ActiveRecord::Migration[5.2]
  def change

    create_table :admin_workspaces do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :admin_roles do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :admin_users do |t|
      t.string :email, index: true, unique: true
      t.string :name
      t.boolean :active
      t.text :options
      t.belongs_to :role
      t.string :remember_digest
      t.string :password_digest
      t.timestamps null: false
    end

    create_table :admin_crud_rules do |t|
      t.belongs_to :role
      t.belongs_to :workspace
      t.timestamps null: false
      t.boolean :c
      t.boolean :r
      t.boolean :u
      t.boolean :d
      t.boolean :s
      t.boolean :p
    end

    create_table :admin_custom_rules do |t|
      t.belongs_to :workspace
      t.string :description
      t.string :code
      t.string :long_description
      t.timestamps null: false
    end

    create_table :admin_custom_role_rules do |t|
      t.belongs_to :custom_rule
      t.belongs_to :role
      t.boolean :access
      t.timestamps null: false
    end

    create_table :admin_access_logs do |t|
      t.belongs_to :workspace
      t.belongs_to :role
      t.belongs_to :user
      t.string :action
      t.string :access_rule
      t.string :details
      t.timestamps null: false
    end

  end
end