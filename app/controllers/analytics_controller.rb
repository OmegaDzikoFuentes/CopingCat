class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    @date_range = params[:range] || '30'
    @start_date = @date_range.to_i.days.ago.beginning_of_day
    @end_date = Time.current.end_of_day

    @emotion_trends = calculate_emotion_trends
    @strategy_effectiveness = calculate_strategy_effectiveness
    @usage_patterns = calculate_usage_patterns
    @wellness_score = calculate_wellness_score
    @achievements = calculate_achievements

    @emotion_stats = current_user.emotional_episodes
                      .where(start_time: @start_date..@end_date)
                      .joins(:emotion)
                      .group('emotions.name')
                      .select('emotions.name, COUNT(*) as frequency, AVG(intensity) as avg_intensity')
                      .order('frequency DESC')

    @trigger_stats = current_user.emotional_episodes
                      .where(start_time: @start_date..@end_date)
                      .joins(:trigger)
                      .group('triggers.name')
                      .select('triggers.name, COUNT(*) as frequency, AVG(intensity) as avg_intensity')
                      .order('frequency DESC')

    @daily_intensity = current_user.emotional_episodes
                        .where(start_time: @start_date..@end_date)
                        .group_by_day(:start_time)
                        .average(:intensity)

    @symptom_stats = PhysicalSymptom.joins(:emotional_episode)
                      .where(emotional_episodes: {
                        user: current_user,
                        start_time: @start_date..@end_date
                      })
                      .group(:name)
                      .select('name, COUNT(*) as frequency, AVG(severity) as avg_severity')
                      .order('frequency DESC')
                      .limit(10)

    @coping_effectiveness = analyze_coping_effectiveness

    @goal_progress = current_user.user_goals.active_goals.map do |goal|
      {
        goal: goal,
        progress: goal.progress_percentage,
        on_track: goal.on_track?
      }
    end

    @engagement_score = current_user.engagement_score
    @weekly_engagement = (0..6).map do |days_ago|
      date = days_ago.days.ago.to_date
      [date, current_user.engagement_score(date)]
    end.reverse
  end

  def emotion_trends
    render json: calculate_emotion_trends
  end

  def emotions
    @emotions = Emotion.all
    @user_emotion_data = {}

    @emotions.each do |emotion|
      episodes = current_user.emotional_episodes.where(emotion: emotion)
      @user_emotion_data[emotion.name] = {
        frequency: episodes.count,
        avg_intensity: episodes.average(:intensity)&.round(2) || 0,
        monthly_trend: episodes.group_by_month(:start_time, last: 6).count
      }
    end
  end

  def triggers
    @triggers = Trigger.all
    @user_trigger_data = {}

    @triggers.each do |trigger|
      episodes = current_user.emotional_episodes.where(trigger: trigger)
      @user_trigger_data[trigger.name] = {
        frequency: episodes.count,
        avg_intensity: episodes.average(:intensity)&.round(2) || 0,
        time_patterns: analyze_trigger_time_patterns(trigger),
        associated_emotions: episodes.joins(:emotion).group('emotions.name').count
      }
    end
  end

  def patterns
    @time_patterns = analyze_time_of_day_patterns
    @context_patterns = analyze_context_patterns
    @trigger_combinations = analyze_trigger_combinations
    @escalation_patterns = analyze_escalation_patterns
  end

  def export
    respond_to do |format|
      format.csv { send_data generate_csv_export, filename: "emotional_data_#{Date.current}.csv" }
      format.json { render json: generate_json_export }
    end
  end

  private

  def calculate_emotion_trends
    current_user.emotional_episodes
                .joins(:emotion)
                .where(created_at: 30.days.ago..Time.current)
                .group('emotions.name')
                .group_by_day(:created_at)
                .average(:intensity)
  end

  def calculate_strategy_effectiveness
    current_user.strategy_usage_logs
                .joins(:coping_strategy)
                .group('coping_strategies.name')
                .average(:effectiveness_rating)
                .sort_by { |_, rating| -rating }
                .first(5)
  end

  def calculate_usage_patterns
    {
      daily_sessions: current_user.app_usages.group_by_day(:timestamp, range: 7.days.ago..Time.current).count,
      peak_hours: current_user.app_usages.group_by_hour_of_day(:timestamp).count,
      session_duration: current_user.app_usages.where.not(session_duration: nil).average(:session_duration)
    }
  end

  def calculate_wellness_score
    recent_episodes = current_user.emotional_episodes.where(created_at: 7.days.ago..Time.current)
    return 50 if recent_episodes.empty?

    avg_intensity = recent_episodes.average(:intensity)
    strategy_usage = current_user.strategy_usage_logs.where(created_at: 7.days.ago..Time.current).count

    base_score = 100 - (avg_intensity * 10)
    usage_bonus = [strategy_usage * 2, 20].min

    [base_score + usage_bonus, 100].min.round
  end

  def calculate_achievements
    achievements = []

    if current_user.app_usages.where(created_at: 7.days.ago..Time.current).count >= 7
      achievements << { name: "Week Warrior", description: "Used the app 7 days in a row!", icon: "🏆" }
    end

    strategy_count = current_user.strategy_usage_logs.count
    if strategy_count >= 10
      achievements << { name: "Strategy Explorer", description: "Tried 10 different coping strategies!", icon: "🧭" }
    end

    recent_avg = current_user.emotional_episodes.where(created_at: 7.days.ago..Time.current).average(:intensity)
    older_avg = current_user.emotional_episodes.where(created_at: 14.days.ago..7.days.ago).average(:intensity)

    if recent_avg && older_avg && recent_avg < older_avg - 1
      achievements << { name: "Getting Better", description: "Your emotional intensity is improving!", icon: "📈" }
    end

    achievements
  end

  def analyze_coping_effectiveness
    strategies_with_effectiveness = {}

    CopingStrategy.joins(:emotional_episodes)
                  .where(emotional_episodes: { user: current_user })
                  .distinct
                  .each do |strategy|

      episodes_with_strategy = current_user.emotional_episodes
                                .joins(:coping_strategies)
                                .where(coping_strategies: { id: strategy.id })

      if episodes_with_strategy.any?
        avg_intensity = episodes_with_strategy.average(:intensity)
        avg_duration = episodes_with_strategy.where.not(end_time: nil)
                        .average('EXTRACT(EPOCH FROM (end_time - start_time))/60')

        strategies_with_effectiveness[strategy.name] = {
          usage_count: episodes_with_strategy.count,
          avg_intensity: avg_intensity&.round(2),
          avg_duration_minutes: avg_duration&.round(2)
        }
      end
    end

    strategies_with_effectiveness
  end

  def analyze_trigger_time_patterns(trigger)
    episodes = current_user.emotional_episodes.where(trigger: trigger)

    {
      by_hour: episodes.group_by_hour_of_day(:start_time).count,
      by_day_of_week: episodes.group_by_day_of_week(:start_time).count,
      by_month: episodes.group_by_month(:start_time, last: 12).count
    }
  end

  def analyze_time_of_day_patterns
    current_user.emotional_episodes
                .group_by_hour_of_day(:start_time)
                .group(:intensity_level)
                .count
  end

  def analyze_context_patterns
    current_user.emotional_episodes
                .joins(:context, :emotion)
                .group('contexts.location', 'contexts.activity', 'emotions.name')
                .count
                .sort_by { |_, count| -count }
                .first(10)
  end

  def analyze_trigger_combinations
    episodes_with_multiple = current_user.emotional_episodes
                              .joins(:episode_trigger_intensities)
                              .group(:id)
                              .having('COUNT(episode_trigger_intensities.id) > 1')
                              .includes(:contributing_triggers)

    combinations = {}
    episodes_with_multiple.each do |episode|
      trigger_names = episode.contributing_triggers.pluck(:name).sort
      combination_key = trigger_names.join(' + ')
      combinations[combination_key] = (combinations[combination_key] || 0) + 1
    end

    combinations.sort_by { |_, count| -count }.first(5)
  end

  def analyze_escalation_patterns
    high_intensity_episodes = current_user.emotional_episodes.high_intensity
    {
      common_triggers: high_intensity_episodes.joins(:trigger).group('triggers.name').count,
      common_emotions: high_intensity_episodes.joins(:emotion).group('emotions.name').count,
      time_to_peak: high_intensity_episodes.where.not(end_time: nil)
                     .average('EXTRACT(EPOCH FROM (end_time - start_time))/60')&.round(2)
    }
  end

  def generate_csv_export
    require 'csv'

    CSV.generate(headers: true) do |csv|
      csv << [
        'Date', 'Emotion', 'Trigger', 'Intensity', 'Duration (minutes)',
        'Physical Symptoms', 'Coping Strategies', 'Context Location',
        'Context Activity', 'Notes'
      ]

      current_user.emotional_episodes.includes(:emotion, :trigger, :physical_symptoms, :coping_strategies, :context).each do |episode|
        csv << [
          episode.start_time.strftime('%Y-%m-%d %H:%M'),
          episode.emotion.name,
          episode.trigger.name,
          episode.intensity,
          episode.duration,
          episode.physical_symptoms.pluck(:name).join('; '),
          episode.coping_strategies.pluck(:name).join('; '),
          episode.context&.location,
          episode.context&.activity,
          episode.notes
        ]
      end
    end
  end

  def generate_json_export
    {
      user: {
        id: current_user.id,
        email: current_user.email,
        export_date: Time.current
      },
      emotional_episodes: current_user.emotional_episodes.includes(:emotion, :trigger, :physical_symptoms, :coping_strategies, :context).map do |episode|
        {
          date: episode.start_time,
          emotion: episode.emotion.name,
          trigger: episode.trigger.name,
          intensity: episode.intensity,
          duration: episode.duration,
          symptoms: episode.physical_symptoms.pluck(:name),
          strategies: episode.coping_strategies.pluck(:name),
          location: episode.context&.location,
          activity: episode.context&.activity,
          notes: episode.notes
        }
      end
    }
  end
end
