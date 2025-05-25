class SocialController < ApplicationController
  before_action :authenticate_user!
  
  def leaderboard
    @top_users = User.joins(:app_usages)
                    .where(app_usages: { created_at: 30.days.ago..Time.current })
                    .group('users.id')
                    .order('COUNT(app_usages.id) DESC')
                    .limit(10)
                    .includes(:cat)
  end
  
  def share_progress
    @wellness_score = calculate_wellness_score
    @streak = calculate_current_streak
    @favorite_strategy = current_user.strategy_usage_logs
                                    .joins(:coping_strategy)
                                    .group('coping_strategies.name')
                                    .order('COUNT(*) DESC')
                                    .first&.coping_strategy
  end
  
  def challenges
    @current_challenges = Challenge.active.includes(:user_challenges)
    @user_challenges = current_user.user_challenges.includes(:challenge)
  end
  
  def join_challenge
    challenge = Challenge.find(params[:id])
    current_user.user_challenges.find_or_create_by(challenge: challenge)
    redirect_to challenges_path, notice: "Challenge accepted! 🎯"
  end
end