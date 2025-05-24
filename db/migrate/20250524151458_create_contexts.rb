class CreateContexts < ActiveRecord::Migration[8.0]
  def change
    create_table :contexts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :location
      t.string :activity
      t.string :social_context
      t.string :physiological
      t.datetime :timestamp

      t.timestamps
    end
  end
end
