class Context < ApplicationRecord
  belongs_to :user
  has_many :diary_entries
  has_many :emotional_episodes
  
  validates :location, length: { maximum: 100 }
  validates :activity, length: { maximum: 100 }
  validates :social_context, length: { maximum: 100 }
  validates :physiological, length: { maximum: 100 }
  
  scope :by_location, ->(location) { where(location: location) }
  scope :by_activity, ->(activity) { where(activity: activity) }
  scope :recent, -> { order(timestamp: :desc) }
end
