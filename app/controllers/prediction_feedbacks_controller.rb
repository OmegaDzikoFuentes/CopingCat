class PredictionFeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  def index
    @feedbacks = current_user.prediction_feedbacks.recent.includes(:predicted_trigger)
    @accuracy_rate = PredictionFeedback.accuracy_rate(current_user)
    @recent_accuracy = PredictionFeedback.accuracy_rate(current_user, 7) # Last week
  end

  def show
  end

  def new
    @feedback = current_user.prediction_feedbacks.build
    @triggers = Trigger.all.order(:name)
    
    # Pre-fill if coming from a prediction
    if params[:prediction_id].present?
      # This would come from your ML prediction system
      @feedback.prediction_timestamp = params[:prediction_time]
      @feedback.predicted_trigger_id = params[:predicted_trigger_id]
      @feedback.confidence_score = params[:confidence]
    end
  end

  def create
    @feedback = current_user.prediction_feedbacks.build(feedback_params)
    @feedback.feedback_timestamp = Time.current
    
    if @feedback.save
      redirect_to @feedback, notice: 'Thank you for your feedback! This helps improve our predictions.'
    else
      @triggers = Trigger.all.order(:name)
      render :new
    end
  end

  def edit
    @triggers = Trigger.all.order(:name)
  end

  def update
    if @feedback.update(feedback_params)
      redirect_to @feedback, notice: 'Feedback was successfully updated.'
    else
      @triggers = Trigger.all.order(:name)
      render :edit
    end
  end

  def destroy
    @feedback.destroy
    redirect_to prediction_feedbacks_url, notice: 'Feedback was successfully deleted.'
  end

  # Quick feedback endpoint for simple yes/no responses
  def quick_feedback
    @feedback = current_user.prediction_feedbacks.build(
      predicted_trigger_id: params[:trigger_id],
      actual_outcome: params[:outcome], # 'accurate' or 'inaccurate'
      prediction_timestamp: params[:prediction_time],
      feedback_timestamp: Time.current,
      confidence_score: params[:confidence]
    )
    
    if @feedback.save
      render json: { success: true, message: 'Thank you for your feedback!' }
    else
      render json: { success: false, errors: @feedback.errors.full_messages }
    end
  end

  private

  def set_feedback
    @feedback = current_user.prediction_feedbacks.find(params[:id])
  end

  def feedback_params
    params.require(:prediction_feedback).permit(
      :predicted_trigger_id, :actual_outcome, :confidence_score,
      :prediction_timestamp, :notes
    )
  end
end