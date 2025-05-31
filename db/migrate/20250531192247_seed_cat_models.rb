class SeedCatModels < ActiveRecord::Migration[7.1]
  def up
    Cat.create!([
      {
        name: "Fluffy",
        model_filename: "fluffy_cat.glb",
        category: "long_hair",
        customizable: true
      },
      {
        name: "Sleek",
        model_filename: "sleek_cat.glb", 
        category: "short_hair",
        customizable: true
      },
      {
        name: "Tabby",
        model_filename: "tabby_cat.glb",
        category: "striped",
        customizable: true
      },
      {
        name: "Spotted",
        model_filename: "spotted_cat.glb",
        category: "spotted", 
        customizable: true
      },
      {
        name: "Default",
        model_filename: "default_cat.glb",
        category: "basic",
        customizable: false
      }
    ])
  end

  def down
    Cat.delete_all
  end
end