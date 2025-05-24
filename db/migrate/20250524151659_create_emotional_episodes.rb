class CreateEmotionalEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :emotional_episodes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :trigger, null: false, foreign_key: true
      t.references :emotion, null: false, foreign_key: true
      t.references :diary_entry, null: false, foreign_key: true
      t.references :context, null: false, foreign_key: true
      t.integer :intensity
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
