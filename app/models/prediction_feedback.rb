class PredictionFeedback < ApplicationRecord
  belongs_to :user
  belongs_to :predicted_trigger, class_name: 'Trigger'
  
  validates :actual_outcome, inclusion: { 
    in: ['accurate', 'partially_accurate', 'inaccurate', 'trigger_avoided', 'different_trigger'] 
  }
  validates :confidence_score, numericality: { in: 0.0..1.0 }, allow_nil: true
  validates :prediction_timestamp, presence: true
  validates :feedback_timestamp, presence: true
  
  scope :accurate, -> { where(actual_outcome: 'accurate') }
  scope :inaccurate, -> { where(actual_outcome: 'inaccurate') }
  scope :recent, -> { order(feedback_timestamp: :desc) }
  
  def self.accuracy_rate(user = nil, days = 30)
    scope = user ? where(user: user) : all
    recent_feedback = scope.where(feedback_timestamp: days.days.ago..Time.current)
    
    return 0 if recent_feedback.count == 0
    
    accurate_count = recent_feedback.where(actual_outcome: ['accurate', 'partially_accurate']).count
    (accurate_count.to_f / recent_feedback.count * 100).round(2)
  end
  
  def prediction_delay_hours
    return nil unless prediction_timestamp && feedback_timestamp
    ((feedback_timestamp - prediction_timestamp) / 1.hour).round(2)
  end
end