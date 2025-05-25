class StrategyUsageLog < ApplicationRecord
    belongs_to :user
    belongs_to :coping_strategy
    belongs_to :emotional_episode, optional: true
    
    validates :effectiveness_rating, inclusion: { in: 1..5 }
    validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
    
    scope :recent, -> { where(created_at: 30.days.ago..Time.current) }
    scope :effective, -> { where(effectiveness_rating: 4..5) }
  end
  
