class UserGoalsController < ApplicationController
  before_action :set_goal, only: [:show, :edit, :update, :destroy, :complete, :pause]

  def index
    @active_goals = current_user.user_goals.active_goals.includes(:target_emotion, :target_trigger)
    @completed_goals = current_user.user_goals.completed_goals.includes(:target_emotion, :target_trigger)
    @due_soon = current_user.user_goals.due_soon.active_goals
  end

  def show
    @progress = @goal.progress_percentage
    @on_track = @goal.on_track?
    
    # Recent episodes related to this goal
    @related_episodes = current_user.emotional_episodes
                         .where(
                           emotion: @goal.target_emotion,
                           trigger: @goal.target_trigger
                         )
                         .recent
                         .limit(10)
  end

  def new
    @goal = current_user.user_goals.build
    @emotions = Emotion.all.order(:name)
    @triggers = Trigger.all.order(:name)
    
    # Suggest goals based on user's most frequent triggers/emotions
    @suggested_triggers = current_user.emotional_episodes
                           .joins(:trigger)
                           .group(:trigger)
                           .order('COUNT(*) DESC')
                           .limit(5)
                           .pluck(:trigger)
  end

  def create
    @goal = current_user.user_goals.build(goal_params)
    
    # Set baseline frequency from recent episodes
    if @goal.target_trigger && @goal.target_emotion
      recent_episodes = current_user.emotional_episodes
                         .where(
                           trigger: @goal.target_trigger,
                           emotion: @goal.target_emotion,
                           start_time: 30.days.ago..Time.current
                         )
      @goal.baseline_frequency = recent_episodes.count
      @goal.current_frequency = recent_episodes.count
    end
    
    if @goal.save
      AppUsage.create(
        user: current_user,
        action: 'set_goal',
        timestamp: Time.current
      )
      
      redirect_to @goal, notice: 'Goal was successfully created.'
    else
      @emotions = Emotion.all.order(:name)
      @triggers = Trigger.all.order(:name)
      render :new
    end
  end

  def edit
    @emotions = Emotion.all.order(:name)
    @triggers = Trigger.all.order(:name)
  end

  def update
    if @goal.update(goal_params)
      redirect_to @goal, notice: 'Goal was successfully updated.'
    else
      @emotions = Emotion.all.order(:name)
      @triggers = Trigger.all.order(:name)
      render :edit
    end
  end

  def destroy
    @goal.destroy
    redirect_to user_goals_url, notice: 'Goal was successfully deleted.'
  end

  def complete
    @goal.update(status: 'completed', completed_at: Time.current)
    redirect_to @goal, notice: 'Congratulations! Goal marked as completed.'
  end

  def pause
    @goal.update(status: 'paused')
    redirect_to @goal, notice: 'Goal has been paused.'
  end

  private

  def set_goal
    @goal = current_user.user_goals.find(params[:id])
  end

  def goal_params
    params.require(:user_goal).permit(
      :target_trigger_id, :target_emotion_id, :target_reduction_percentage,
      :deadline, :description, :status
    )
  end
end