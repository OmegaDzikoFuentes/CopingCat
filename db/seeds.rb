# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing cats (optional - remove if you want to keep existing data)
Cat.delete_all

# Create cat models
cats = [
  {
    name: "Fluffy Persian",
    model_filename: "persian_cat.glb",
    category: "long_hair",
    customizable: true
  },
  {
    name: "Sleek Siamese", 
    model_filename: "siamese_cat.glb",
    category: "short_hair",
    customizable: true
  },
  {
    name: "Tabby Cat",
    model_filename: "tabby_cat.glb", 
    category: "striped",
    customizable: true
  },
  {
    name: "Maine Coon",
    model_filename: "maine_coon.glb",
    category: "large",
    customizable: true
  },
  {
    name: "British Shorthair",
    model_filename: "british_shorthair.glb",
    category: "round",
    customizable: true
  },
  {
    name: "Default Cat",
    model_filename: "default_cat.glb",
    category: "basic",
    customizable: false
  }
]

cats.each do |cat_attrs|
  Cat.find_or_create_by(name: cat_attrs[:name]) do |cat|
    cat.model_filename = cat_attrs[:model_filename]
    cat.category = cat_attrs[:category] 
    cat.customizable = cat_attrs[:customizable]
  end
end

puts "Created #{Cat.count} cat models"