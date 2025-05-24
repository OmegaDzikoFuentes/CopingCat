class Tag < ApplicationRecord
    has_many :episode_tags, dependent: :destroy
    has_many :emotional_episodes, through: :episode_tags
    
    validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
    validates :category, length: { maximum: 50 }
    
    scope :by_category, ->(category) { where(category: category) }
    scope :ml_tags, -> { where(category: 'ML') }
    scope :user_tags, -> { where(category: 'User') }
  end