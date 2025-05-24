class BehaviorReactionsController < ApplicationController
  before_action :set_episode
  before_action :set_reaction, only: [:show, :edit, :update, :destroy]

  def index
    @reactions = @episode.behavior_reactions.order(:created_at)
    @positive_reactions = @reactions.select(&:positive_reaction?)
    @concerning_reactions = @reactions.select(&:needs_attention?)
  end

  def show
  end

  def new
    @reaction = @episode.behavior_reactions.build
  end

  def create
    @reaction = @episode.behavior_reactions.build(reaction_params)
    
    if @reaction.save
      # Check for concerning reactions and potentially alert
      if @reaction.needs_attention?
        flash[:alert] = "We notice you're experiencing some challenging reactions. Consider reaching out for support."
      end
      
      redirect_to [@episode, @reaction], notice: 'Behavior reaction was successfully logged.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @reaction.update(reaction_params)
      redirect_to [@episode, @reaction], notice: 'Behavior reaction was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @reaction.destroy
    redirect_to [@episode, :behavior_reactions], notice: 'Behavior reaction was successfully removed.'
  end

  private

  def set_episode
    @episode = current_user.emotional_episodes.find(params[:emotional_episode_id])
  end

  def set_reaction
    @reaction = @episode.behavior_reactions.find(params[:id])
  end

  def reaction_params
    params.require(:behavior_reaction).permit(:action_type, :description, :duration_minutes)
  end
end
