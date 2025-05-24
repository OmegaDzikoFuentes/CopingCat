class AnalyticsController < ApplicationController
  def dashboard
    @date_range = params[:range] || '30'
    @start_date = @date_range.to_i.days.ago.beginning_of_day
    @end_date = Time.current.end_of_day
    
    # Emotion frequency and intensity
    @emotion_stats = current_user.emotional_episodes
                      .where(start_time: @start_date..@end_date)
                      .joins(:emotion)
                      .group('emotions.name')
                      .select('emotions.name, COUNT(*) as frequency, AVG(intensity) as avg_intensity')
                      .order('frequency DESC')
    
    # Trigger analysis
    @trigger_stats = current_user.emotional_episodes
                      .where(start_time: @start_date..@end_date)
                      .joins(:trigger)
                      .group('triggers.name')
                      .select('triggers.name, COUNT(*) as frequency, AVG(intensity) as avg_intensity')
                      .order('frequency DESC')
    
    # Daily intensity trends
    @daily_intensity = current_user.emotional_episodes
                        .where(start_time: @start_date..@end_date)
                        .group_by_day(:start_time)
                        .average(:intensity)
    
    # Physical symptoms frequency
    @symptom_stats = PhysicalSymptom.joins(:emotional_episode)
                      .where(emotional_episodes: { 
                        user: current_user, 
                        start_time: @start_date..@end_date 
                      })
                      .group(:name)
                      .select('name, COUNT(*) as frequency, AVG(severity) as avg_severity')
                      .order('frequency DESC')
                      .limit(10)
    
    # Coping strategy effectiveness
    @coping_effectiveness = analyze_coping_effectiveness
    
    # Goal progress
    @goal_progress = current_user.user_goals.active_goals.map do |goal|
      {
        goal: goal,
        progress: goal.progress_percentage,
        on_track: goal.on_track?
      }
    end
    
    # Engagement metrics
    @engagement_score = current_user.engagement_score
    @weekly_engagement = (0..6).map do |days_ago|
      date = days_ago.days.ago.to_date
      [date, current_user.engagement_score(date)]
    end.reverse
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
    # Identify patterns in user's emotional episodes
    @time_patterns = analyze_time_of_day_patterns
    @context_patterns = analyze_context_patterns
    @trigger_combinations = analyze_trigger_combinations
    @escalation_patterns = analyze_escalation_patterns
  end

  def export
    # Export user data (could be CSV, JSON, or PDF)
    respond_to do |format|
      format.csv { send_data generate_csv_export, filename: "emotional_data_#{Date.current}.csv" }
      format.json { render json: generate_json_export }
    end
  end

  private

  def analyze_coping_effectiveness
    strategies_with_effectiveness = {}
    
    CopingStrategy.joins(:emotional_episodes)
                  .where(emotional_episodes: { user: current_user })
                  .distinct
                  .each do |strategy|
      
      # Find episodes where this strategy was used
      episodes_with_strategy = current_user.emotional_episodes
                                .joins(:coping_strategies)
                                .where(coping_strategies: { id: strategy.id })
      
      # Compare intensity before/after or duration
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
    # Analyze patterns in contexts where episodes occur
    context_emotions = current_user.emotional_episodes
                        .joins(:context, :emotion)
                        .group('contexts.location', 'contexts.activity', 'emotions.name')
                        .count
                        .sort_by { |_, count| -count }
                        .first(10)
    
    context_emotions
  end

  def analyze_trigger_combinations
    # Find episodes with multiple triggers
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
    # Look for patterns in intensity escalation
    high_intensity_episodes = current_user.emotional_episodes.high_intensity
    patterns = {
      common_triggers: high_intensity_episodes.joins(:trigger).group('triggers.name').count,
      common_emotions: high_intensity_episodes.joins(:emotion).group('emotions.name').count,
      time_to_peak: high_intensity_episodes.where.not(end_time: nil)
                     .average('EXTRACT(EPOCH FROM (end_time - start_time))/60')&.round(2)
    }
    
    patterns
  end

  def generate_csv_export
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Headers
      csv << [
        'Date', 'Emotion', 'Trigger', 'Intensity', 'Duration (minutes)',
        'Physical Symptoms', 'Coping Strategies', 'Context Location',
        'Context Activity', 'Notes'
      ]
      
      # Data rows
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
      emotional_episodes: current_user.emotional_episodes.includes(:emotion, :trigger, :physical_symptoms, :coping_strategies).map do |episode|
        {
          id: episode.id,
          emotion: episode.emotion.name,
          trigger: episode.trigger.name,
          intensity: episode.intensity,
          start_time: episode.start_time,
          end_time: episode.end_time,
          duration_minutes: episode.duration,
          notes: episode.notes,
          physical_symptoms: episode.physical_symptoms.map do |symptom|
            {
              name: symptom.name,
              severity: symptom.severity,
              notes: symptom.notes
            }
          end,
          coping_strategies: episode.coping_strategies.pluck(:name),
          behavior_reactions: episode.behavior_reactions.map do |reaction|
            {
              action_type: reaction.action_type,
              description: reaction.description,
              duration_minutes: reaction.duration_minutes
            }
          end
        }
      end,
      diary_entries: current_user.diary_entries.includes(:emotion).map do |entry|
        {
          id: entry.id,
          notes: entry.notes,
          emotion: entry.emotion&.name,
          intensity: entry.intensity,
          location: entry.location,
          activity: entry.activity,
          entry_time: entry.entry_time
        }
      end,
      goals: current_user.user_goals.includes(:target_emotion, :target_trigger).map do |goal|
        {
          id: goal.id,
          target_emotion: goal.target_emotion.name,
          target_trigger: goal.target_trigger.name,
          target_reduction_percentage: goal.target_reduction_percentage,
          deadline: goal.deadline,
          status: goal.status,
          progress_percentage: goal.progress_percentage,
          created_at: goal.created_at
        }
      end
    }
  end
end
