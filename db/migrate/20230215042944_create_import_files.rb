class CreateImportFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :import_files do |t|
      t.string :name
      t.text :options
      t.timestamps
    end
  end
end
