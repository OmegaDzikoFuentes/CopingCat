class DiaryEntriesController < ApplicationController
  before_action :set_diary_entry, only: [:show, :edit, :update, :destroy]

  def index
    @diary_entries = current_user.diary_entries
                      .includes(:emotion, :context)
                      .recent
                      .page(params[:page])
    
    @filter_emotions = current_user.diary_entries.joins(:emotion).distinct.pluck('emotions.name', 'emotions.id')
    
    # Apply filters
    @diary_entries = @diary_entries.by_emotion(params[:emotion_id]) if params[:emotion_id].present?
    @diary_entries = @diary_entries.by_intensity_range(params[:min_intensity], params[:max_intensity]) if params[:min_intensity].present?
    @diary_entries = @diary_entries.where(entry_time: params[:start_date]..params[:end_date]) if params[:start_date].present?
  end

  def show
    @related_episodes = @diary_entry.emotional_episodes.includes(:trigger, :emotion, :physical_symptoms)
  end

  def new
    @diary_entry = current_user.diary_entries.build
    @emotions = Emotion.all.order(:name)
    @contexts = current_user.contexts.recent.limit(10)
  end

  def create
    @diary_entry = current_user.diary_entries.build(diary_entry_params)
    @diary_entry.entry_time = Time.current if @diary_entry.entry_time.blank?
    
    if @diary_entry.save
      # Track usage
      AppUsage.create(
        user: current_user,
        action: 'diary_entry',
        timestamp: Time.current
      )
      
      redirect_to @diary_entry, notice: 'Diary entry was successfully created.'
    else
      @emotions = Emotion.all.order(:name)
      @contexts = current_user.contexts.recent.limit(10)
      render :new
    end
  end

  def edit
    @emotions = Emotion.all.order(:name)
    @contexts = current_user.contexts.recent.limit(10)
  end

  def update
    if @diary_entry.update(diary_entry_params)
      redirect_to @diary_entry, notice: 'Diary entry was successfully updated.'
    else
      @emotions = Emotion.all.order(:name)
      @contexts = current_user.contexts.recent.limit(10)
      render :edit
    end
  end

  def destroy
    @diary_entry.destroy
    redirect_to diary_entries_url, notice: 'Diary entry was successfully deleted.'
  end

  private

  def set_diary_entry
    @diary_entry = current_user.diary_entries.find(params[:id])
  end

  def diary_entry_params
    params.require(:diary_entry).permit(:notes, :intensity, :location, :activity, :entry_time, :emotion_id, :context_id)
  end
end

