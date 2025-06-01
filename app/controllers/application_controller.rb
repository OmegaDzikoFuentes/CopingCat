class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_user_activity
  before_action :load_user_cat, if: :user_signed_in?
  before_action :check_emotional_state, if: :user_signed_in?

  protected

  def load_user_cat
    @current_cat = UserCatCustomization.includes(:cat).find_by(user_id: current_user.id)
    @cat_should_suggest_game = should_cat_suggest_game?
  end

  def should_cat_suggest_game?
    return false unless current_user.emotional_episodes.any?
    
    # Check if recent episodes have high intensity
    recent_high_intensity = current_user.emotional_episodes
                                       .where(created_at: 24.hours.ago..Time.current)
                                       .where('intensity >= ?', 7)
                                       .exists?
    recent_high_intensity
  end

  def check_emotional_state
    @wellness_suggestion = generate_wellness_suggestion if @cat_should_suggest_game
  end

  def generate_wellness_suggestion
    suggestions = [
      "Your cat thinks you might enjoy a quick game to lighten your mood! 🎮",
      "Meow! How about we play a fun game together? 🐱",
      "Your feline friend suggests taking a break with a game! ✨",
      "Your cat is purring... maybe it's time for some playful distraction? 🎯"
    ]
    suggestions.sample
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :age, :gender, :occupation, lifestyle: []])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :age, :gender, :occupation, lifestyle: []])
  end

  def track_user_activity
    return unless user_signed_in? && request.get? && should_track?
    
    AppUsage.create(
      user: current_user,
      action: determine_action,
      timestamp: Time.current,
      session_duration: session[:session_start] ? (Time.current - session[:session_start]).to_i : nil
    )
  end

  def should_track?
  %w[diary_entries emotional_episodes analytics].include?(controller_name)
  end

  def determine_action
    case controller_name
    when 'diary_entries' then 'diary_entry'
    when 'emotional_episodes' then 'episode_log'
    when 'analytics' then 'view_analytics'
    when 'coping_strategies' then 'use_coping_strategy'
    when 'user_goals' then 'set_goal'
    else 'login'
    end
  end
end