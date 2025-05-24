class CreatePhysicalSymptoms < ActiveRecord::Migration[8.0]
  def change
    create_table :physical_symptoms do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.string :name
      t.integer :severity

      t.timestamps
    end
  end
end
