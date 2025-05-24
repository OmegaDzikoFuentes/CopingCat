class CreateDiaryEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :diary_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :emotion, null: false, foreign_key: true
      t.references :context, null: false, foreign_key: true
      t.text :notes
      t.integer :intensity
      t.string :location
      t.string :activity
      t.datetime :entry_time

      t.timestamps
    end
  end
end
