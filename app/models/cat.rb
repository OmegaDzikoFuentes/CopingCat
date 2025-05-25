class Cat < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :model_filename, presence: true, uniqueness: true
    validates :category, presence: true
  
    scope :defaults, -> { where(customizable: false) }
    scope :customizable, -> { where(customizable: true) }
  
    def self.random_cat
      defaults.order('RANDOM()').first
    end
  end
