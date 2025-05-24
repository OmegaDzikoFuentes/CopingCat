class Api::V1::EmotionalEpisodesController < Api::V1::BaseController
  def index
    @episodes = current_user.emotional_episodes
                 .includes(:emotion, :trigger, :physical_symptoms)
                 .recent
                 .limit(params[:limit] || 20)
    
    render json: @episodes.as_json(
      include: {
        emotion: { only: [:id, :name, :category] },
        trigger: { only: [:id, :name, :category] },
        physical_symptoms: { only: [:name, :severity] }
      }
    )
  end

  def create
    @episode = current_user.emotional_episodes.build(episode_params)
    @episode.start_time = Time.current if @episode.start_time.blank?
    
    if @episode.save
      # Add physical symptoms if provided
      if params[:physical_symptoms].present?
        params[:physical_symptoms].each do |symptom|
          @episode.physical_symptoms.create(
            name: symptom[:name],
            severity: symptom[:severity] || 5
          )
        end
      end
      
      render json: @episode.as_json(
        include: {
          emotion: { only: [:id, :name] },
          trigger: { only: [:id, :name] },
          physical_symptoms: { only: [:name, :severity] }
        }
      ), status: :created
    else
      render json: { errors: @episode.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    @episode = current_user.emotional_episodes.find(params[:id])
    render json: @episode.as_json(
      include: {
        emotion: { only: [:id, :name, :category] },
        trigger: { only: [:id, :name, :category] },
        physical_symptoms: { only: [:name, :severity, :notes] },
        coping_strategies: { only: [:id, :name, :category] },
        behavior_reactions: { only: [:action_type, :description] }
      }
    )
  end

  private

  def episode_params
    params.require(:emotional_episode).permit(
      :emotion_id, :trigger_id, :intensity, :start_time, :end_time, :notes
    )
  end
end