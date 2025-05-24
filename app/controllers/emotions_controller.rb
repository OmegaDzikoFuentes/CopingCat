class EmotionsController < ApplicationController
  before_action :set_emotion, only: [:show, :edit, :update, :destroy]

  def index
    @emotions = Emotion.all
    @emotions_by_category = @emotions.group_by(&:category)
    
    # Analytics for current user
    @user_emotion_stats = current_user.emotional_episodes
                           .joins(:emotion)
                           .group('emotions.name')
                           .average(:intensity)
                           .transform_values { |v| v.round(2) }
  end

  def show
    @average_intensity = @emotion.average_intensity(current_user)
    @recent_episodes = current_user.emotional_episodes
                        .where(emotion: @emotion)
                        .recent
                        .limit(10)
                        .includes(:physical_symptoms, :coping_strategies)
  end

  def new
    @emotion = Emotion.new
  end

  def create
    @emotion = Emotion.new(emotion_params)
    
    if @emotion.save
      redirect_to @emotion, notice: 'Emotion was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @emotion.update(emotion_params)
      redirect_to @emotion, notice: 'Emotion was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @emotion.destroy
    redirect_to emotions_url, notice: 'Emotion was successfully deleted.'
  end

  private

  def set_emotion
    @emotion = Emotion.find(params[:id])
  end

  def emotion_params
    params.require(:emotion).permit(:name, :category, :description)
  end
end