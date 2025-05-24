class EpisodeTag < ApplicationRecord
  belongs_to :emotional_episode
  belongs_to :tag
  
  validates :emotional_episode_id, uniqueness: { scope: :tag_id }
end