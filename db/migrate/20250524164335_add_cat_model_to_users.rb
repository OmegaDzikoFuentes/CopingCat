class AddCatModelToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :cat_model, :string
  end
end
