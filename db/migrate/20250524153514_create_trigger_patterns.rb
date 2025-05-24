class CreateTriggerPatterns < ActiveRecord::Migration[8.0]
  def change
    create_table :trigger_patterns do |t|
      t.references :trigger, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :frequency
      t.string :time_of_day

      t.timestamps
    end
  end
end
