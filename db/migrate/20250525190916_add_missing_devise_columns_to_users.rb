class AddMissingDeviseColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_column :users, :email, :string, null: false, default: ""
    add_column :users, :encrypted_password, :string, null: false, default: ""
  end
end
