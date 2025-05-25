class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.integer :age
      t.string :gender
      t.string :occupation
      t.text :lifestyle

      t.timestamps
    end
  end
end
