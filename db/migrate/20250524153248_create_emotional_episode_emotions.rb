class CreateEmotionalEpisodeEmotions < ActiveRecord::Migration[7.1]
  def change
    create_table :emotional_episode_emotions do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.references :emotion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
