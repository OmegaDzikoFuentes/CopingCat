class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :track_user_activity

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :age, :gender, :occupation, lifestyle: []])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :age, :gender, :occupation, lifestyle: []])
  end

  def track_user_activity
    return unless user_signed_in? && request.get?
    
    AppUsage.create(
      user: current_user,
      action: determine_action,
      timestamp: Time.current,
      session_duration: session[:session_start] ? (Time.current - session[:session_start]).to_i : nil
    )
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