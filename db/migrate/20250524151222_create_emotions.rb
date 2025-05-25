class CreateEmotions < ActiveRecord::Migration[7.1]
  def change
    create_table :emotions do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
