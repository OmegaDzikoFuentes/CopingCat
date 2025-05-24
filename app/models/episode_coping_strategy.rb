class EpisodeCopingStrategy < ApplicationRecord
  belongs_to :emotional_episode
  belongs_to :coping_strategy
  
  validates :emotional_episode_id, uniqueness: { scope: :coping_strategy_id }
  
  scope :with_notes, -> { where.not(notes: [nil, '']) }
end