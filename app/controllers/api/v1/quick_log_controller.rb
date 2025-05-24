class Api::V1::QuickLogController < Api::V1::BaseController
  # Simplified endpoint for quick emotion logging
  def create
    @episode = current_user.emotional_episodes.build(
      emotion_id: params[:emotion_id],
      trigger_id: params[:trigger_id],
      intensity: params[:intensity],
      start_time: Time.current,
      notes: params[:notes]
    )
    
    if @episode.save
      # Add single physical symptom if provided
      if params[:physical_symptom].present?
        @episode.physical_symptoms.create(
          name: params[:physical_symptom],
          severity: params[:symptom_severity] || 5
        )
      end
      
      render json: {
        success: true,
        episode: @episode.as_json(include: :emotion),
        message: 'Episode logged successfully'
      }, status: :created
    else
      render json: {
        success: false,
        errors: @episode.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
