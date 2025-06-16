class GameController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_cat, only: [:index, :breathing_exercise, :fortune_teller, :mood_booster]
  
  # Main game dashboard - matches views/game/index.html.erb
  def index
    @user = current_user
    @cat_model = @user_cat&.model_filename || assign_random_cat
    @recent_episodes = current_user.emotional_episodes.recent.limit(3)
    @wellness_score = calculate_wellness_score
    @streak = calculate_streak
    @available_games = [
      { name: 'Emotion Mapping', path: game_questions_path, description: 'Explore your emotions', icon: '🧠' },
      { name: 'Over Stacked', path: game_over_stacked_path, description: 'Tetris-like mindfulness game', icon: '🧩' },
      { name: 'Breathing Exercise', path: game_breathing_exercise_path, description: 'Calm your mind', icon: '🌬️' },
      { name: 'Magic 8 Ball', path: game_magic_eight_ball_path, description: 'Get insights', icon: '🎱' },
      { name: 'Fortune Teller', path: game_fortune_teller_path, description: 'Future guidance', icon: '🔮' },
      { name: 'Mood Booster', path: game_mood_booster_path, description: 'Lift your spirits', icon: '⭐' }
    ]
  end
  
  # 4 emotion question bubbles - matches views/game/questions.html.erb
  def questions
    @question_types = [
      { 
        id: 'triggered', 
        title: 'I feel triggered', 
        description: 'Something upset me and I need to process it',
        color: 'bg-red-100 hover:bg-red-200',
        icon: '😤',
        path: game_emotion_mapping_path(question_type: 'triggered')
      },
      { 
        id: 'overwhelmed', 
        title: 'I feel overwhelmed', 
        description: 'Everything feels like too much right now',
        color: 'bg-orange-100 hover:bg-orange-200',
        icon: '😰',
        path: game_emotion_mapping_path(question_type: 'overwhelmed')
      },
      { 
        id: 'disconnected', 
        title: 'I feel disconnected', 
        description: 'I feel isolated or sad',
        color: 'bg-blue-100 hover:bg-blue-200',
        icon: '😢',
        path: game_emotion_mapping_path(question_type: 'disconnected')
      },
      { 
        id: 'need_breath', 
        title: 'I need to breathe', 
        description: 'I need to calm down and center myself',
        color: 'bg-green-100 hover:bg-green-200',
        icon: '🌬️',
        path: game_breathing_exercise_path
      }
    ]
  end
  
  # Multi-step emotion form - matches views/game/emotion_mapping.html.erb
  def emotion_mapping
    @question_type = params[:question_type]
    @emotion_map = get_emotion_map(@question_type)
    
    # Handle invalid question types
    unless @emotion_map
      flash[:error] = "Invalid question type"
      redirect_to game_questions_path and return
    end
    
    @step = params[:step]&.to_i || 1
    @max_steps = @emotion_map[:questions].length
    @current_question = @emotion_map[:questions][@step - 1]
    
    # Initialize or update session data
    session[:emotion_data] ||= {}
    session[:emotion_data][:question_type] = @question_type
    session[:emotion_data][:primary_emotion] = @emotion_map[:primary]
    
    # Set progress indicators
    @progress_percentage = (@step.to_f / @max_steps * 100).round
    @is_final_step = @step == @max_steps
  end
  
  # Process emotion mapping form submissions
  def process_emotion_step
    emotion_data = session[:emotion_data] || {}
    current_step = params[:current_step].to_i
    
    # Process different question types
    case params[:question_type]
    when 'intensity'
      emotion_data[:intensity] = params[:intensity]
    when 'trigger'
      emotion_data[:trigger] = params[:trigger]
    when 'physical'
      emotion_data[:physical_symptoms] = params[:physical_symptoms] || []
    end
    
    session[:emotion_data] = emotion_data
    
    # Determine next step or generate strategy
    max_steps = get_emotion_map(emotion_data[:question_type])[:questions].length
    
    if current_step < max_steps
      redirect_to game_emotion_mapping_path(
        question_type: emotion_data[:question_type], 
        step: current_step + 1
      )
    else
      redirect_to game_generate_strategy_path
    end
  end
  
  # Strategy results page - matches views/game/generate_strategy.html.erb
  def generate_strategy
    @emotion_data = session[:emotion_data]
    
    unless @emotion_data&.dig(:primary_emotion)
      flash[:error] = "Please complete the emotion mapping first"
      redirect_to game_questions_path and return
    end
    
    @strategy = generate_coping_strategy(@emotion_data)
    @alternative_strategies = get_alternative_strategies(@emotion_data)
    @cat = @user_cat || assign_random_cat
    
    # Save to database
    @episode = save_emotional_episode(@emotion_data, @strategy)
    
    # Track strategy usage
    track_strategy_usage(@strategy, @emotion_data)
    
    # Clear session data
    session.delete(:emotion_data)
  end
  
  # NEW: Tetris-like mindfulness game - matches views/game/over_stacked.html.erb
  def over_stacked
    @cat = @user_cat || assign_random_cat
    @game_settings = {
      difficulty: params[:difficulty] || 'normal',
      theme: params[:theme] || 'mindful',
      duration: params[:duration] || 300 # 5 minutes default
    }
    @mindfulness_prompts = get_mindfulness_prompts
  end
  
  # Breathing exercise interface - matches views/game/breathing_exercise.html.erb
  def breathing_exercise
    @cat = @user_cat || assign_random_cat
    @breathing_exercises = [
      { 
        id: 'four_seven_eight',
        name: '4-7-8 Breathing', 
        duration: 60, 
        description: 'Inhale 4, hold 7, exhale 8',
        pattern: { inhale: 4, hold: 7, exhale: 8 }
      },
      { 
        id: 'box_breathing',
        name: 'Box Breathing', 
        duration: 120, 
        description: '4-4-4-4 pattern for focus',
        pattern: { inhale: 4, hold: 4, exhale: 4, pause: 4 }
      },
      { 
        id: 'calm_breathing',
        name: 'Calm Breathing', 
        duration: 180, 
        description: 'Simple deep breathing',
        pattern: { inhale: 4, exhale: 6 }
      }
    ]
    @selected_exercise = find_exercise_by_id(params[:exercise]) || @breathing_exercises.first
  end
  
  # Magic 8-ball game - matches views/game/magic_eight_ball.html.erb
  def magic_eight_ball
    @question = params[:question]
    @cat = @user_cat || assign_random_cat
    @answers = [
      { text: "It is certain", type: "positive" },
      { text: "Reply hazy, try again", type: "neutral" },
      { text: "Don't count on it", type: "negative" },
      { text: "It is decidedly so", type: "positive" },
      { text: "Ask again later", type: "neutral" },
      { text: "My reply is no", type: "negative" },
      { text: "Without a doubt", type: "positive" },
      { text: "Better not tell you now", type: "neutral" },
      { text: "My sources say no", type: "negative" },
      { text: "Yes definitely", type: "positive" },
      { text: "Cannot predict now", type: "neutral" },
      { text: "Outlook not so good", type: "negative" },
      { text: "You may rely on it", type: "positive" },
      { text: "Concentrate and ask again", type: "neutral" },
      { text: "Very doubtful", type: "negative" },
      { text: "As I see it, yes", type: "positive" },
      { text: "Most likely", type: "positive" },
      { text: "Outlook good", type: "positive" },
      { text: "Yes", type: "positive" },
      { text: "Signs point to yes", type: "positive" }
    ]
    
    if @question.present?
      @answer = @answers.sample
      # Track magic 8 ball usage
      track_game_usage('magic_eight_ball', { question_asked: true })
    end
  end
  
  # Fortune telling game - matches views/game/fortune_teller.html.erb
  def fortune_teller
    @cat = @user_cat || assign_random_cat
    @fortune_categories = [
      { id: 'general', name: 'General Guidance', icon: '🌟' },
      { id: 'love', name: 'Love & Relationships', icon: '💕' },
      { id: 'career', name: 'Career & Goals', icon: '💼' },
      { id: 'wellness', name: 'Health & Wellness', icon: '🌿' }
    ]
    
    @selected_category = params[:category] || 'general'
    @fortune = generate_fortune(@selected_category)
    
    # Track fortune teller usage
    track_game_usage('fortune_teller', { category: @selected_category })
  end
  
  # Mood boosting activities - matches views/game/mood_booster.html.erb
  def mood_booster
    @cat = @user_cat || assign_random_cat
    @booster_type = params[:type] || 'affirmation'
    @booster_categories = [
      { id: 'affirmation', name: 'Affirmations', icon: '💪', description: 'Positive self-talk' },
      { id: 'joke', name: 'Jokes', icon: '😄', description: 'A good laugh' },
      { id: 'quote', name: 'Quotes', icon: '📖', description: 'Inspiring words' },
      { id: 'activity', name: 'Activities', icon: '🎯', description: 'Quick mood lifters' },
      { id: 'gratitude', name: 'Gratitude', icon: '🙏', description: 'Count your blessings' }
    ]
    
    case @booster_type
    when 'affirmation'
      @content = get_affirmation
    when 'joke'
      @content = get_joke
    when 'quote'
      @content = get_inspirational_quote
    when 'activity'
      @content = get_mood_boosting_activity
    when 'gratitude'
      @content = get_gratitude_prompt
    else
      @content = get_affirmation
    end
    
    # Track mood booster usage
    track_game_usage('mood_booster', { type: @booster_type })
  end
  
  private

  def calculate_wellness_score
    recent_episodes = current_user.emotional_episodes.where('created_at > ?', 7.days.ago)
    return 50 if recent_episodes.empty?
    
    avg_intensity = recent_episodes.average(:intensity) || 5
    ((10 - avg_intensity) * 10).round
  end
  
  def calculate_streak
    usage_dates = current_user.app_usages
                             .where('created_at > ?', 30.days.ago)
                             .group_by { |usage| usage.created_at.to_date }
                             .keys
                             .sort
    
    return 0 if usage_dates.empty?
    
    streak = 1
    usage_dates.reverse.each_cons(2) do |current, previous|
      break unless (current - previous).to_i == 1
      streak += 1
    end
    
    streak
  end
  
  def set_user_cat
    @user_cat = current_user.user_cat_customizations.includes(:cat).first&.cat ||
                current_user.cat ||
                Cat.where(category: 'default').first
  end
  
  def assign_random_cat
    available_cats = Cat.where(category: 'default')
    selected_cat = available_cats.sample
    
    if selected_cat
      current_user.update!(cat_model: selected_cat.model_filename)
      selected_cat.model_filename
    else
      'default_cat'
    end
  end
  
  def get_emotion_map(question_type)
    emotion_maps = {
      'triggered' => {
        primary: 'anger',
        questions: [
          { text: "How intense is this feeling?", type: "intensity", emotion: "anger", scale: "1-10" },
          { text: "What triggered this reaction?", type: "trigger", input_type: "textarea" },
          { text: "Where do you feel it in your body?", type: "physical", options: ["Head", "Chest", "Stomach", "Shoulders", "Hands"] }
        ]
      },
      'overwhelmed' => {
        primary: 'anxiety',
        questions: [
          { text: "How overwhelming does it feel?", type: "intensity", emotion: "anxiety", scale: "1-10" },
          { text: "What's contributing to this feeling?", type: "trigger", input_type: "textarea" },
          { text: "Are you feeling physical symptoms?", type: "physical", options: ["Racing heart", "Sweaty palms", "Tight chest", "Restlessness", "Fatigue"] }
        ]
      },
      'disconnected' => {
        primary: 'sadness',
        questions: [
          { text: "How deep is this feeling?", type: "intensity", emotion: "sadness", scale: "1-10" },
          { text: "When did you start feeling this way?", type: "trigger", input_type: "textarea" },
          { text: "What physical sensations do you notice?", type: "physical", options: ["Heavy feeling", "Low energy", "Tearful", "Empty feeling", "Tired"] }
        ]
      },
      'need_breath' => {
        primary: 'stress',
        questions: [
          { text: "How stressed are you feeling?", type: "intensity", emotion: "stress", scale: "1-10" },
          { text: "What's making you feel this way?", type: "trigger", input_type: "textarea" },
          { text: "How is your body responding?", type: "physical", options: ["Tense muscles", "Shallow breathing", "Headache", "Jittery", "Exhausted"] }
        ]
      }
    }
    
    emotion_maps[question_type]
  end
  
  def find_exercise_by_id(exercise_id)
    @breathing_exercises&.find { |ex| ex[:id] == exercise_id }
  end
  
  def get_mindfulness_prompts
    [
      "Notice your breath as blocks fall",
      "Each cleared line is a moment of presence",
      "Stay calm as the pace increases",
      "Focus on the present piece",
      "Let go of perfect placement"
    ]
  end
  
  def generate_fortune(category)
    fortunes = {
      'general' => [
        "A period of growth awaits you",
        "Trust your intuition today",
        "New perspectives will bring clarity",
        "Your patience will be rewarded",
        "Embrace the changes coming your way"
      ],
      'love' => [
        "Open your heart to new connections",
        "Self-love is the foundation of all love",
        "A meaningful conversation awaits",
        "Kindness will open unexpected doors",
        "Your authentic self attracts true love"
      ],
      'career' => [
        "Your hard work will soon be recognized",
        "A new opportunity is on the horizon",
        "Trust your professional instincts",
        "Collaboration will lead to success",
        "Your unique skills are needed"
      ],
      'wellness' => [
        "Listen to what your body needs",
        "Small healthy choices create big changes",
        "Rest is productive too",
        "Your mental health matters most",
        "Balance will bring you peace"
      ]
    }
    
    fortunes[category]&.sample || fortunes['general'].sample
  end
  
  def generate_coping_strategy(emotion_data)
    primary_emotion = emotion_data[:primary_emotion]
    intensity = emotion_data[:intensity].to_i
    
    base_strategies = CopingStrategy.where(category: map_emotion_to_category(primary_emotion))
    strategies = filter_strategies_by_intensity(base_strategies, intensity)
    strategies = personalize_strategies(strategies)
    
    strategies.sample || create_fallback_strategy(primary_emotion)
  end
  
  def get_alternative_strategies(emotion_data)
    primary_emotion = emotion_data[:primary_emotion]
    base_strategies = CopingStrategy.where(category: map_emotion_to_category(primary_emotion))
    base_strategies.limit(3).offset(1)
  end
  
  def save_emotional_episode(emotion_data, strategy)
    emotion = Emotion.find_or_create_by(name: emotion_data[:primary_emotion]) do |e|
      e.category = map_emotion_to_category(emotion_data[:primary_emotion])
    end
    
    context = current_user.contexts.create!(
      location: 'Game Interface',
      activity: 'Using Coping Cat Game',
      timestamp: Time.current
    )
    
    diary_entry = current_user.diary_entries.create!(
      emotion: emotion,
      context: context,
      notes: "Generated via Coping Cat game: #{emotion_data[:trigger]}",
      intensity: emotion_data[:intensity],
      entry_time: Time.current
    )
    
    episode = current_user.emotional_episodes.create!(
      emotion: emotion,
      diary_entry: diary_entry,
      context: context,
      trigger_id: find_or_create_trigger(emotion_data[:trigger]).id,
      intensity: emotion_data[:intensity],
      start_time: Time.current,
      end_time: Time.current + 1.hour
    )
    
    if emotion_data[:physical_symptoms]&.any?
      emotion_data[:physical_symptoms].each do |symptom|
        episode.physical_symptoms.create!(name: symptom, severity: 3)
      end
    end
    
    episode.episode_coping_strategies.create!(
      coping_strategy: strategy,
      notes: "Recommended by Coping Cat game"
    )
    
    episode
  end
  
  def track_strategy_usage(strategy, emotion_data)
    current_user.strategy_usage_logs.create!(
      coping_strategy: strategy,
      created_at: Time.current
    )
  end
  
  def track_game_usage(game_type, metadata = {})
    current_user.app_usages.create!(
      action: "play_#{game_type}",
      timestamp: Time.current,
      session_duration: 0
    )
  end
  
  def map_emotion_to_category(emotion)
    emotion_categories = {
      'anger' => 'anger',
      'anxiety' => 'anxiety', 
      'sadness' => 'sadness',
      'stress' => 'stress',
      'fear' => 'anxiety',
      'joy' => 'positive',
      'disgust' => 'negative'
    }
    emotion_categories[emotion] || 'general'
  end
  
  def filter_strategies_by_intensity(strategies, intensity)
    if intensity >= 8
      strategies.where('difficulty_level <= ? OR difficulty_level IS NULL', 2)
    elsif intensity >= 5
      strategies.where('difficulty_level <= ? OR difficulty_level IS NULL', 3)
    else
      strategies
    end
  end
  
  def personalize_strategies(strategies)
    successful_strategy_ids = current_user.episode_coping_strategies
                                        .where('effectiveness >= ?', 4)
                                        .joins(:coping_strategy)
                                        .pluck('coping_strategies.id')
    
    if successful_strategy_ids.any?
      preferred = strategies.where(id: successful_strategy_ids)
      preferred.any? ? preferred : strategies
    else
      strategies
    end
  end
  
  def create_fallback_strategy(emotion)
    CopingStrategy.find_or_create_by(name: 'Deep Breathing') do |strategy|
      strategy.category = 'general'
    end
  end
  
  def find_or_create_trigger(trigger_description)
    Trigger.find_or_create_by(name: trigger_description) do |trigger|
      trigger.category = 'personal'
      trigger.trigger_type = 'internal'
    end
  end
  
  def get_affirmation
    [
      "You are stronger than you think",
      "This feeling will pass",
      "You have overcome challenges before",
      "You are worthy of love and happiness",
      "Every day is a new opportunity",
      "You are exactly where you need to be",
      "Your feelings are valid and important",
      "You have the power to choose your response"
    ].sample
  end
  
  def get_joke
    [
      "Why don't scientists trust atoms? Because they make up everything!",
      "What do you call a bear with no teeth? A gummy bear!",
      "Why did the scarecrow win an award? He was outstanding in his field!",
      "What do you call a fake noodle? An impasta!",
      "Why don't eggs tell jokes? They'd crack each other up!"
    ].sample
  end
  
  def get_inspirational_quote
    [
      "The only way out is through. - Robert Frost",
      "You are braver than you believe. - A.A. Milne", 
      "Progress, not perfection. - Anonymous",
      "What lies behind us and what lies before us are tiny matters compared to what lies within us. - Ralph Waldo Emerson",
      "The present moment is the only time over which we have dominion. - Thích Nhất Hạnh"
    ].sample
  end
  
  def get_mood_boosting_activity
    [
      "Take a 5-minute walk outside",
      "Listen to your favorite song",
      "Call someone you care about",
      "Write down 3 things you're grateful for",
      "Do 10 jumping jacks",
      "Take 5 deep breaths",
      "Smile at yourself in the mirror",
      "Stretch your arms above your head"
    ].sample
  end
  
  def get_gratitude_prompt
    [
      "What made you smile today?",
      "Who in your life are you most grateful for?",
      "What's one thing about your body you appreciate?",
      "What opportunity are you thankful for?",
      "What's a simple pleasure that brings you joy?"
    ].sample
  end
end