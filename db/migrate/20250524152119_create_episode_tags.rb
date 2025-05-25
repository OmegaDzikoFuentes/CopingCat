class CreateEpisodeTags < ActiveRecord::Migration[7.1]
  def change
    create_table :episode_tags do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
