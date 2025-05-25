class CreateCopingStrategies < ActiveRecord::Migration[7.1]
  def change
    create_table :coping_strategies do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
