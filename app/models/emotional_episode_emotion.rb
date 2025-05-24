class EmotionalEpisodeEmotion < ApplicationRecord
  belongs_to :emotional_episode
  belongs_to :emotion
  
  validates :emotional_episode_id, uniqueness: { scope: :emotion_id }
  validates :intensity, numericality: { in: 1..10 }, allow_nil: true
  
  scope :high_intensity, -> { where(intensity: 8..10) }
  scope :by_emotion, ->(emotion) { where(emotion: emotion) }
end