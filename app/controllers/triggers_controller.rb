class TriggersController < ApplicationController
  before_action :set_trigger, only: [:show, :edit, :update, :destroy]

  def index
    @triggers = Trigger.all.order(:category, :name)
    @triggers_by_category = @triggers.group_by(&:category)
    
    # User-specific trigger analytics
    @user_trigger_stats = current_user.emotional_episodes
                           .joins(:trigger)
                           .group('triggers.name')
                           .select('triggers.name, COUNT(*) as frequency, AVG(intensity) as avg_intensity')
                           .order('frequency DESC')
  end

  def show
    @frequency = @trigger.frequency_for_user(current_user)
    @average_intensity = @trigger.average_intensity_for_user(current_user)
    @recent_episodes = current_user.emotional_episodes
                        .where(trigger: @trigger)
                        .recent
                        .limit(10)
                        .includes(:emotion, :physical_symptoms)
    
    @trigger_patterns = current_user.trigger_patterns.where(trigger: @trigger)
  end

  def new
    @trigger = Trigger.new
  end

  def create
    @trigger = Trigger.new(trigger_params)
    
    if @trigger.save
      redirect_to @trigger, notice: 'Trigger was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @trigger.update(trigger_params)
      redirect_to @trigger, notice: 'Trigger was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @trigger.destroy
    redirect_to triggers_url, notice: 'Trigger was successfully deleted.'
  end

  private

  def set_trigger
    @trigger = Trigger.find(params[:id])
  end

  def trigger_params
    params.require(:trigger).permit(:name, :category, :trigger_type, :description)
  end
end
