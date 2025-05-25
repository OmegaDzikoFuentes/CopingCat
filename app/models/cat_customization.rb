class CatCustomization < ApplicationRecord
    belongs_to :user
    
    validates :customization_type, inclusion: { in: %w[color accessory pattern] }
    validates :value, presence: true
  end