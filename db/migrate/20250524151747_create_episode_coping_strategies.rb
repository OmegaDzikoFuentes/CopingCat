class CreateEpisodeCopingStrategies < ActiveRecord::Migration[8.0]
  def change
    create_table :episode_coping_strategies do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.references :coping_strategy, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
