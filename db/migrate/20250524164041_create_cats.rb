class CreateCats < ActiveRecord::Migration[7.1]
  def change
    create_table :cats do |t|
      t.string :name
      t.string :model_filename
      t.string :category
      t.boolean :customizable

      t.timestamps
    end
  end
end
