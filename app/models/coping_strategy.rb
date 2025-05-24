class CopingStrategy < ApplicationRecord
    has_many :episode_coping_strategies, dependent: :destroy
    has_many :emotional_episodes, through: :episode_coping_strategies
    
    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
    validates :category, length: { maximum: 50 }
    
    scope :by_category, ->(category) { where(category: category) }
    scope :relaxation, -> { where(category: 'Relaxation') }
    scope :exercise, -> { where(category: 'Exercise') }
    scope :social, -> { where(category: 'Social') }
  end