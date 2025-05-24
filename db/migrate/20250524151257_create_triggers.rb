class CreateTriggers < ActiveRecord::Migration[8.0]
  def change
    create_table :triggers do |t|
      t.string :name
      t.string :category
      t.string :trigger_type

      t.timestamps
    end
  end
end
