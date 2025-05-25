class CreateEpisodeTriggerIntensities < ActiveRecord::Migration[7.1]
  def change
    create_table :episode_trigger_intensities do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.references :trigger, null: false, foreign_key: true
      t.integer :weight

      t.timestamps
    end
  end
end
