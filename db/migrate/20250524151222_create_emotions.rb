class CreateEmotions < ActiveRecord::Migration[8.0]
  def change
    create_table :emotions do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
