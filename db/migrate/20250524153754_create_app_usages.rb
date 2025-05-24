class CreateAppUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :app_usages do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action
      t.datetime :timestamp

      t.timestamps
    end
  end
end
