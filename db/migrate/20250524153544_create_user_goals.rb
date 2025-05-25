class CreateUserGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :user_goals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :target_trigger, null: false, foreign_key: true
      t.references :target_emotion, null: false, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
