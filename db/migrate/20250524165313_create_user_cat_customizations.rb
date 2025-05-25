class CreateUserCatCustomizations < ActiveRecord::Migration[7.1]
  def change
    create_table :user_cat_customizations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :color
      t.string :accessory
      t.string :texture

      t.timestamps
    end
  end
end
