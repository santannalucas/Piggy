class AddNavbarToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admin_users, :navbar, :text
  end
end
