class EmotionalEpisodesController < ApplicationController
  before_action :set_episode, only: [:show, :edit, :update, :destroy]

  def index
    @episodes = current_user.emotional_episodes
                 .includes(:emotion, :trigger, :physical_symptoms, :coping_strategies)
                 .recent
                 .page(params[:page])
    
    # Filters
    @episodes = @episodes.by_emotion(params[:emotion_id]) if params[:emotion_id].present?
    @episodes = @episodes.by_trigger(params[:trigger_id]) if params[:trigger_id].present?
    @episodes = @episodes.by_intensity(params[:intensity]) if params[:intensity].present?
    @episodes = @episodes.where(start_time: params[:start_date]..params[:end_date]) if params[:start_date].present?
    
    @filter_emotions = Emotion.joins(:emotional_episodes).where(emotional_episodes: { user: current_user }).distinct
    @filter_triggers = Trigger.joins(:emotional_episodes).where(emotional_episodes: { user: current_user }).distinct
  end

  def show
    @physical_symptoms = @episode.physical_symptoms.order(:severity)
    @coping_strategies = @episode.coping_strategies
    @behavior_reactions = @episode.behavior_reactions
    @secondary_emotions = @episode.secondary_emotions
  end

  def new
    @episode = current_user.emotional_episodes.build
    @emotions = Emotion.all.order(:name)
    @triggers = Trigger.all.order(:name)
    @contexts = current_user.contexts.recent.limit(10)
    @coping_strategies = CopingStrategy.all.order(:category, :name)
  end

  def create
    @episode = current_user.emotional_episodes.build(episode_params)
    @episode.start_time = Time.current if @episode.start_time.blank?
    
    ActiveRecord::Base.transaction do
      if @episode.save
        # Add physical symptoms
        create_physical_symptoms
        
        # Add coping strategies
        create_coping_strategies
        
        # Add behavior reactions
        create_behavior_reactions
        
        # Add secondary emotions
        create_secondary_emotions
        
        # Track usage
        AppUsage.create(
          user: current_user,
          action: 'episode_log',
          timestamp: Time.current
        )
        
        redirect_to @episode, notice: 'Emotional episode was successfully logged.'
      else
        raise ActiveRecord::Rollback
      end
    end
    
    if @episode.persisted?
      # Success handled above
    else
      load_form_data
      render :new
    end
  end

  def edit
    load_form_data
  end

  def update
    ActiveRecord::Base.transaction do
      if @episode.update(episode_params)
        # Update physical symptoms
        @episode.physical_symptoms.destroy_all
        create_physical_symptoms
        
        # Update coping strategies
        @episode.episode_coping_strategies.destroy_all
        create_coping_strategies
        
        # Update behavior reactions
        @episode.behavior_reactions.destroy_all
        create_behavior_reactions
        
        # Update secondary emotions
        @episode.emotional_episode_emotions.destroy_all
        create_secondary_emotions
        
        redirect_to @episode, notice: 'Emotional episode was successfully updated.'
      else
        raise ActiveRecord::Rollback
      end
    end
    
    unless @episode.errors.empty?
      load_form_data
      render :edit
    end
  end

  def destroy
    @episode.destroy
    redirect_to emotional_episodes_url, notice: 'Emotional episode was successfully deleted.'
  end

  # Quick logging endpoint for simplified episode creation
  def quick_log
    @episode = current_user.emotional_episodes.build
    @common_emotions = Emotion.joins(:emotional_episodes)
                        .where(emotional_episodes: { user: current_user })
                        .group('emotions.id')
                        .order('COUNT(*) DESC')
                        .limit(5)
    @common_triggers = Trigger.joins(:emotional_episodes)
                        .where(emotional_episodes: { user: current_user })
                        .group('triggers.id')
                        .order('COUNT(*) DESC')
                        .limit(5)
  end

  def create_quick
    @episode = current_user.emotional_episodes.build(quick_episode_params)
    @episode.start_time = Time.current
    
    if @episode.save
      # Add single physical symptom if provided
      if params[:physical_symptom].present?
        @episode.physical_symptoms.create(
          name: params[:physical_symptom],
          severity: params[:symptom_severity] || 5
        )
      end
      
      redirect_to @episode, notice: 'Episode quickly logged! Add more details if needed.'
    else
      @common_emotions = Emotion.limit(5)
      @common_triggers = Trigger.limit(5)
      render :quick_log
    end
  end

  private

  def set_episode
    @episode = current_user.emotional_episodes.find(params[:id])
  end

  accepts_nested_attributes_for :physical_symptoms, :coping_strategies, allow_destroy: true

  def episode_params
    params.require(:emotional_episode).permit(
      :emotion_id, :trigger_id, :intensity, :start_time, :end_time, 
      :notes, :context_id, :diary_entry_id, physical_symptoms_attributes: [:id, :name, :severity, :notes, :_destroy],
      coping_strategy_attributes: [:id, :strategy_id, :notes, :_destroy]
    )
  end

  def quick_episode_params
    params.require(:emotional_episode).permit(:emotion_id, :trigger_id, :intensity, :notes)
  end

  def load_form_data
    @emotions = Emotion.all.order(:name)
    @triggers = Trigger.all.order(:name)
    @contexts = current_user.contexts.recent.limit(10)
    @coping_strategies = CopingStrategy.all.order(:category, :name)
  end

  def create_physical_symptoms
    return unless params[:physical_symptoms].present?
    
    params[:physical_symptoms].each do |symptom_params|
      next if symptom_params[:name].blank?
      
      @episode.physical_symptoms.create(
        name: symptom_params[:name],
        severity: symptom_params[:severity] || 5,
        notes: symptom_params[:notes]
      )
    end
  end

  def create_coping_strategies
    return unless params[:coping_strategy_ids].present?
    
    params[:coping_strategy_ids].each do |strategy_id|
      next if strategy_id.blank?
      
      @episode.episode_coping_strategies.create(
        coping_strategy_id: strategy_id,
        notes: params[:coping_notes]&.dig(strategy_id)
      )
    end
  end

  def create_behavior_reactions
    return unless params[:behavior_reactions].present?
    
    params[:behavior_reactions].each do |reaction_params|
      next if reaction_params[:action_type].blank?
      
      @episode.behavior_reactions.create(
        action_type: reaction_params[:action_type],
        description: reaction_params[:description],
        duration_minutes: reaction_params[:duration_minutes]
      )
    end
  end

  def create_secondary_emotions
    return unless params[:secondary_emotion_ids].present?
    
    params[:secondary_emotion_ids].each do |emotion_id|
      next if emotion_id.blank?
      
      @episode.emotional_episode_emotions.create(
        emotion_id: emotion_id,
        intensity: params[:secondary_intensities]&.dig(emotion_id) || 5
      )
    end
  end
end