class CreateCatCustomizations < ActiveRecord::Migration[7.1]
  def change
    create_table :cat_customizations do |t|
      t.timestamps
    end
  end
end
