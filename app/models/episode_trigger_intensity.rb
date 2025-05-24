class EpisodeTriggerIntensity < ApplicationRecord
  belongs_to :emotional_episode
  belongs_to :trigger
  
  validates :weight, numericality: { in: 1..10 }
  validates :emotional_episode_id, uniqueness: { scope: :trigger_id }
  
  scope :high_weight, -> { where(weight: 8..10) }
  scope :medium_weight, -> { where(weight: 4..7) }
  scope :low_weight, -> { where(weight: 1..3) }
  
  def weight_level
    case weight
    when 1..3
      'low'
    when 4..7
      'medium'
    when 8..10
      'high'
    end
  end
end