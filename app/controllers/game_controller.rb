class GameController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # Main game entry point
    @user = current_user
    @cat_model = current_user.cat_model || assign_random_cat
  end
  
  def questions
    # Display the 4 main question bubbles
    render :questions
  end
  
  def emotion_mapping
    @question_type = params[:question_type]
    @emotion_map = get_emotion_map(@question_type)
    render :emotion_mapping
  end
  
  def generate_strategy
    @emotion_data = params[:emotion_data]
    @strategy = generate_coping_strategy(@emotion_data)
    
    # Save to database
    emotional_episode = current_user.emotional_episodes.create!(
      emotion: Emotion.find_by(name: @emotion_data[:primary_emotion]),
      intensity: @emotion_data[:intensity],
      trigger_description: @emotion_data[:trigger],
      notes: "Generated via Coping Cat game"
    )
    
    # Add physical symptoms if present
    if @emotion_data[:physical_symptoms].present?
      @emotion_data[:physical_symptoms].each do |symptom|
        emotional_episode.physical_symptoms.create!(symptom_name: symptom)
      end
    end
    
    # Track strategy usage
    AppUsage.create!(
      user: current_user,
      action: 'use_coping_strategy',
      details: { strategy: @strategy.name, emotion: @emotion_data[:primary_emotion] }
    )
    
    render :strategy
  end
  
  def breathing_exercise
    render :breathing
  end
  
  private
  
  def assign_random_cat
    available_cats = Cat.where(category: 'default').pluck(:model_filename)
    selected_cat = available_cats.sample
    current_user.update!(cat_model: selected_cat)
    selected_cat
  end
  
  def get_emotion_map(question_type)
    {
      'triggered' => {
        primary: 'anger',
        questions: [
          { text: "How intense is this feeling?", type: "intensity", emotion: "anger" },
          { text: "What triggered this reaction?", type: "trigger" },
          { text: "Where do you feel it in your body?", type: "physical" }
        ]
      },
      'overwhelmed' => {
        primary: 'anxiety',
        questions: [
          { text: "How overwhelming does it feel?", type: "intensity", emotion: "anxiety" },
          { text: "What's contributing to this feeling?", type: "trigger" },
          { text: "Are you feeling physical symptoms?", type: "physical" }
        ]
      },
      'disconnected' => {
        primary: 'sadness',
        questions: [
          { text: "How deep is this feeling?", type: "intensity", emotion: "sadness" },
          { text: "When did you start feeling this way?", type: "trigger" },
          { text: "What physical sensations do you notice?", type: "physical" }
        ]
      },
      'need_breath' => {
        primary: 'stress',
        questions: [
          { text: "How stressed are you feeling?", type: "intensity", emotion: "stress" },
          { text: "What's making you feel this way?", type: "trigger" },
          { text: "How is your body responding?", type: "physical" }
        ]
      }
    }[question_type]
  end
  
  def generate_coping_strategy(emotion_data)
    primary_emotion = emotion_data[:primary_emotion]
    intensity = emotion_data[:intensity].to_i
    
    # Get strategies for this emotion
    base_strategies = CopingStrategy.where(emotion_category: primary_emotion)
    
    # Filter by intensity (high intensity gets different strategies)
    if intensity >= 8
      strategies = base_strategies.where('difficulty_level <= ?', 2) # Easier strategies for high intensity
    elsif intensity >= 5
      strategies = base_strategies.where('difficulty_level <= ?', 3)
    else
      strategies = base_strategies # All strategies available
    end
    
    # Personalize based on user's past successful strategies
    successful_strategies = current_user.strategy_usage_logs
                                      .where(effectiveness_rating: 4..5)
                                      .joins(:coping_strategy)
                                      .pluck('coping_strategies.id')
    
    if successful_strategies.any?
      # Prefer strategies that worked before
      preferred = strategies.where(id: successful_strategies)
      strategies = preferred.any? ? preferred : strategies
    end
    
    strategies.sample
  end
end
