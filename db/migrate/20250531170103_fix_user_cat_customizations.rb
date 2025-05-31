class FixUserCatCustomizations < ActiveRecord::Migration[7.1]
  def change
    # Add missing columns
    add_column :user_cat_customizations, :cat_id, :integer
    add_column :user_cat_customizations, :base_color, :string
    add_column :user_cat_customizations, :accent_color, :string
    
    # Remove the old 'color' column if you want to replace it
    # remove_column :user_cat_customizations, :color
    
    # Add foreign key constraint
    add_foreign_key :user_cat_customizations, :cats, column: :cat_id
    
    # Add index
    add_index :user_cat_customizations, :cat_id
  end
end
