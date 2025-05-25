class AddCatModelToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :cat_model, :string
  end
end
