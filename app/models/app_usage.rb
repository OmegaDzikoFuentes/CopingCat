class AppUsage < ApplicationRecord
  belongs_to :user
  
  validates :action, presence: true, inclusion: { 
    in: ['login', 'logout', 'diary_entry', 'episode_log', 'view_analytics', 
         'use_coping_strategy', 'set_goal', 'complete_assessment', 'export_data'] 
  }
  validates :timestamp, presence: true
  validates :session_duration, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :recent, -> { order(timestamp: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :today, -> { where(timestamp: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(timestamp: 1.week.ago..Time.current) }
  scope :engagement_actions, -> { where(action: ['diary_entry', 'episode_log', 'use_coping_strategy']) }
  
  def self.daily_engagement_score(user, date = Date.current)
    actions = where(user: user, timestamp: date.beginning_of_day..date.end_of_day)
    engagement_actions = actions.engagement_actions.count
    total_duration = actions.sum(:session_duration) || 0
    
    # Simple scoring: engagement actions * 10 + duration in minutes / 10
    (engagement_actions * 10) + (total_duration / 10.0).round
  end
end
