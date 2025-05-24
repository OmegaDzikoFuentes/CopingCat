class DiaryEntry < ApplicationRecord
  belongs_to :user
  belongs_to :emotion, optional: true
  belongs_to :context, optional: true
  has_many :emotional_episodes, dependent: :nullify
  
  validates :notes, presence: true
  validates :intensity, numericality: { in: 1..10 }, allow_nil: true
  validates :location, length: { maximum: 100 }
  validates :activity, length: { maximum: 100 }
  validates :entry_time, presence: true
  
  scope :recent, -> { order(entry_time: :desc) }
  scope :by_emotion, ->(emotion) { where(emotion: emotion) }
  scope :by_intensity_range, ->(min, max) { where(intensity: min..max) }
  scope :today, -> { where(entry_time: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(entry_time: 1.week.ago..Time.current) }
end