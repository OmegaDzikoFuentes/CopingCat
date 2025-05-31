class Cat < ApplicationRecord
  has_many :user_cat_customizations, dependent: :destroy
  has_many :users, through: :user_cat_customizations

  validates :name, presence: true
  validates :model_filename, presence: true
  validates :category, presence: true

  def self.random_cat
    order("RANDOM()").first || create_default
  end

  def self.create_default
    find_or_create_by(name: "Default Cat") do |cat|
      cat.model_filename = "default_cat.glb"
      cat.category = "basic"
      cat.customizable = false
    end
  end
end

