class CreateBehaviorReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :behavior_reactions do |t|
      t.references :emotional_episode, null: false, foreign_key: true
      t.string :action_type

      t.timestamps
    end
  end
end
