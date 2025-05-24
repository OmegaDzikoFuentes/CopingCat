class CopingStrategiesController < ApplicationController
  before_action :set_strategy, only: [:show, :edit, :update, :destroy, :use]

  def index
    @strategies = CopingStrategy.all.order(:category, :name)
    @strategies_by_category = @strategies.group_by(&:category)
    
    # User's most used strategies
    @user_strategies = current_user.emotional_episodes
                        .joins(:coping_strategies)
                        .group('coping_strategies.name')
                        .count
                        .sort_by { |_, count| -count }
                        .first(5)
  end

  def show
    @usage_count = @strategy.emotional_episodes
                    .where(user: current_user)
                    .count
    
    @recent_usage = current_user.emotional_episodes
                     .joins(:coping_strategies)
                     .where(coping_strategies: { id: @strategy.id })
                     .recent
                     .limit(5)
  end

  def new
    @strategy = CopingStrategy.new
  end

  def create
    @strategy = CopingStrategy.new(strategy_params)
    
    if @strategy.save
      redirect_to @strategy, notice: 'Coping strategy was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @strategy.update(strategy_params)
      redirect_to @strategy, notice: 'Coping strategy was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @strategy.destroy
    redirect_to coping_strategies_url, notice: 'Coping strategy was successfully deleted.'
  end

  # Quick use endpoint for immediate strategy application
  def use
    # This would typically be called via AJAX during an active episode
    if params[:episode_id].present?
      episode = current_user.emotional_episodes.find(params[:episode_id])
      episode.episode_coping_strategies.find_or_create_by(
        coping_strategy: @strategy
      ) do |ecs|
        ecs.notes = params[:notes]
      end
      
      AppUsage.create(
        user: current_user,
        action: 'use_coping_strategy',
        timestamp: Time.current
      )
      
      render json: { success: true, message: "#{@strategy.name} applied to episode" }
    else
      render json: { success: false, message: "No active episode found" }
    end
  end

  private

  def set_strategy
    @strategy = CopingStrategy.find(params[:id])
  end

  def strategy_params
    params.require(:coping_strategy).permit(:name, :category, :description, :instructions)
  end
end
