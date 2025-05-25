class UserChallenge < ApplicationRecord
    belongs_to :user
    belongs_to :challenge
    
    validates :user_id, uniqueness: { scope: :challenge_id }
    
    def progress_percentage
      return 0 unless challenge.target_value > 0
      
      current_progress = calculate_current_progress
      [(current_progress.to_f / challenge.target_value * 100).round, 100].min
    end
    
    def completed?
      progress_percentage >= 100
    end
    
    private
    
    def calculate_current_progress
      case challenge.challenge_type
      when 'daily_usage'
        user.app_usages.where(created_at: created_at..Time.current).group_by_day(:created_at).count.keys.length
      when 'strategy_count'
        user.strategy_usage_logs.where(created_at: created_at..Time.current).count
      when 'emotion_tracking'
        user.emotional_episodes.where(created_at: created_at..Time.current).count
      when 'wellness_score'
        user.wellness_score
      else
        0
      end
    end
  end
  