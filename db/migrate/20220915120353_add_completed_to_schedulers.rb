class AddCompletedToSchedulers < ActiveRecord::Migration[5.2]
  def change
    add_column :schedulers, :completed, :boolean, :default => false
  end
end
