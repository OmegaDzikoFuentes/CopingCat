class CreatePredictionFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :predicted_trigger, null: false, foreign_key: true
      t.string :actual_outcome

      t.timestamps
    end
  end
end
