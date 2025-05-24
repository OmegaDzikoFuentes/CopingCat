class PhysicalSymptomsController < ApplicationController
  before_action :set_episode
  before_action :set_symptom, only: [:show, :edit, :update, :destroy]

  def index
    @symptoms = @episode.physical_symptoms.order(:severity)
    @common_symptoms = PhysicalSymptom::COMMON_SYMPTOMS
  end

  def show
  end

  def new
    @symptom = @episode.physical_symptoms.build
    @common_symptoms = PhysicalSymptom::COMMON_SYMPTOMS
  end

  def create
    @symptom = @episode.physical_symptoms.build(symptom_params)
    
    if @symptom.save
      redirect_to [@episode, @symptom], notice: 'Physical symptom was successfully added.'
    else
      @common_symptoms = PhysicalSymptom::COMMON_SYMPTOMS
      render :new
    end
  end

  def edit
    @common_symptoms = PhysicalSymptom::COMMON_SYMPTOMS
  end

  def update
    if @symptom.update(symptom_params)
      redirect_to [@episode, @symptom], notice: 'Physical symptom was successfully updated.'
    else
      @common_symptoms = PhysicalSymptom::COMMON_SYMPTOMS
      render :edit
    end
  end

  def destroy
    @symptom.destroy
    redirect_to [@episode, :physical_symptoms], notice: 'Physical symptom was successfully removed.'
  end

  # Quick add endpoint for AJAX requests
  def quick_add
    @symptom = @episode.physical_symptoms.build(
      name: params[:name],
      severity: params[:severity] || 5
    )
    
    if @symptom.save
      render json: { 
        success: true, 
        symptom: {
          id: @symptom.id,
          name: @symptom.name,
          severity: @symptom.severity,
          severity_level: @symptom.severity_level
        }
      }
    else
      render json: { success: false, errors: @symptom.errors.full_messages }
    end
  end

  private

  def set_episode
    @episode = current_user.emotional_episodes.find(params[:emotional_episode_id])
  end

  def set_symptom
    @symptom = @episode.physical_symptoms.find(params[:id])
  end

  def symptom_params
    params.require(:physical_symptom).permit(:name, :severity, :notes)
  end
end