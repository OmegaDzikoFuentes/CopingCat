class TriggerPattern < ApplicationRecord
  belongs_to :trigger
  belongs_to :user
  
  validates :frequency, inclusion: { in: ['daily', 'weekly', 'monthly', 'occasional', 'rare'] }
  validates :time_of_day, inclusion: { in: ['morning', 'afternoon', 'evening', 'night', 'anytime'] }
  validates :user_id, uniqueness: { scope: [:trigger_id, :time_of_day] }
  
  scope :frequent, -> { where(frequency: ['daily', 'weekly']) }
  scope :by_time, ->(time) { where(time_of_day: time) }
  scope :by_frequency, ->(freq) { where(frequency: freq) }
end