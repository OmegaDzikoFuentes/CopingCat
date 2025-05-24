class ContextsController < ApplicationController
  before_action :set_context, only: [:show, :edit, :update, :destroy]

  def index
    @contexts = current_user.contexts.recent.page(params[:page])
  end

  def show
    @related_episodes = @context.emotional_episodes.recent.includes(:emotion, :trigger)
    @related_diary_entries = @context.diary_entries.recent.includes(:emotion)
  end

  def new
    @context = current_user.contexts.build
    # Pre-fill with current location if available (would need geolocation)
    @context.timestamp = Time.current
  end

  def create
    @context = current_user.contexts.build(context_params)
    @context.timestamp = Time.current if @context.timestamp.blank?
    
    if @context.save
      redirect_to @context, notice: 'Context was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @context.update(context_params)
      redirect_to @context, notice: 'Context was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @context.destroy
    redirect_to contexts_url, notice: 'Context was successfully deleted.'
  end

  private

  def set_context
    @context = current_user.contexts.find(params[:id])
  end

  def context_params
    params.require(:context).permit(:location, :activity, :social_context, :physiological, :timestamp)
  end
end

