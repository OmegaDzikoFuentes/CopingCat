class Emotion < ApplicationRecord
    has_many :diary_entries
    has_many :emotional_episodes
    has_many :emotional_episode_emotions
    has_many :user_goals, foreign_key: 'target_emotion_id'
    
    validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
    validates :category, length: { maximum: 20 }
    
    scope :by_category, ->(category) { where(category: category) }
    scope :negative, -> { where(category: 'Negative') }
    scope :positive, -> { where(category: 'Positive') }
    
    def average_intensity(user = nil)
      episodes = user ? emotional_episodes.where(user: user) : emotional_episodes
      episodes.average(:intensity)&.round(2) || 0
    end
  end