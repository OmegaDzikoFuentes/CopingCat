class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :name, :string, if_not_exists: true
    add_column :users, :age, :integer, if_not_exists: true
    add_column :users, :gender, :string, if_not_exists: true
    add_column :users, :occupation, :string, if_not_exists: true
  end
end

