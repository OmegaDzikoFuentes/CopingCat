class Challenge < ApplicationRecord
    has_many :user_challenges, dependent: :destroy
    has_many :users, through: :user_challenges
    
    validates :name, presence: true
    validates :description, presence: true
    validates :target_value, presence: true, numericality: { greater_than: 0 }
    validates :challenge_type, inclusion: { in: %w[daily_usage strategy_count emotion_tracking wellness_score] }
    
    scope :active, -> { where(active: true) }
  end