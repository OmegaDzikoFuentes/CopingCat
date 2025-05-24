class CreateCopingStrategies < ActiveRecord::Migration[8.0]
  def change
    create_table :coping_strategies do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
