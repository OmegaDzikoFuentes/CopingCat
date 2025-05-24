class UserGoal < ApplicationRecord
  belongs_to :user
  belongs_to :target_trigger, class_name: 'Trigger'
  belongs_to :target_emotion, class_name: 'Emotion'
  
  enum status: { 
    active: 0, 
    completed: 1, 
    paused: 2, 
    abandoned: 3 
  }
  
  validates :target_reduction_percentage, numericality: { in: 0..100 }, allow_nil: true
  validates :deadline, presence: true
  validates :status, presence: true
  
  scope :active_goals, -> { where(status: 'active') }
  scope :completed_goals, -> { where(status: 'completed') }
  scope :due_soon, -> { where(deadline: Date.current..1.week.from_now) }
  
  def progress_percentage
    return 0 unless baseline_frequency && current_frequency
    
    improvement = baseline_frequency - current_frequency
    return 0 if improvement <= 0
    
    (improvement.to_f / baseline_frequency * 100).round(2)
  end
  
  def on_track?
    return false unless deadline && created_at
    
    days_total = (deadline - created_at.to_date).to_i
    days_elapsed = (Date.current - created_at.to_date).to_i
    expected_progress = (days_elapsed.to_f / days_total * 100)
    
    progress_percentage >= expected_progress
  end
end