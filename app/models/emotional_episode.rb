class EmotionalEpisode < ApplicationRecord
  belongs_to :user
  belongs_to :trigger
  belongs_to :emotion
  belongs_to :diary_entry, optional: true
  belongs_to :context, optional: true
  
  has_many :episode_coping_strategies, dependent: :destroy
  has_many :coping_strategies, through: :episode_coping_strategies
  has_many :episode_tags, dependent: :destroy
  has_many :tags, through: :episode_tags
  has_many :emotional_episode_emotions, dependent: :destroy
  has_many :secondary_emotions, through: :emotional_episode_emotions, source: :emotion
  has_many :physical_symptoms, dependent: :destroy
  has_many :episode_trigger_intensities, dependent: :destroy
  has_many :contributing_triggers, through: :episode_trigger_intensities, source: :trigger
  has_many :behavior_reactions, dependent: :destroy
  
  validates :intensity, presence: true, numericality: { in: 1..10 }
  validates :start_time, presence: true
  validate :end_time_after_start_time, if: :end_time?
  
  scope :recent, -> { order(start_time: :desc) }
  scope :by_emotion, ->(emotion) { where(emotion: emotion) }
  scope :by_trigger, ->(trigger) { where(trigger: trigger) }
  scope :by_intensity, ->(intensity) { where(intensity: intensity) }
  scope :high_intensity, -> { where(intensity: 8..10) }
  scope :medium_intensity, -> { where(intensity: 4..7) }
  scope :low_intensity, -> { where(intensity: 1..3) }
  scope :today, -> { where(start_time: Date.current.beginning_of_day..Date.current.end_of_day) }
  scope :this_week, -> { where(start_time: 1.week.ago..Time.current) }
  scope :with_physical_symptoms, -> { joins(:physical_symptoms).distinct }
  scope :with_multiple_triggers, -> { joins(:episode_trigger_intensities).group(:id).having('COUNT(episode_trigger_intensities.id) > 1') }
  
  # Helper methods for intensity classification
  def intensity_level
    case intensity
    when 1..3
      'low'
    when 4..7
      'medium'
    when 8..10
      'high'
    end
  end
  
  def duration
    return nil unless end_time && start_time
    ((end_time - start_time) / 1.minute).round
  end
  
  def has_concerning_reactions?
    behavior_reactions.any?(&:needs_attention?)
  end
  
  def positive_coping_used?
    behavior_reactions.any?(&:positive_reaction?)
  end
  
  def severity_score
    # Combine intensity, physical symptoms severity, and negative behaviors
    base_score = intensity
    symptom_boost = physical_symptoms.maximum(:severity) || 0
    behavior_penalty = behavior_reactions.select(&:needs_attention?).count * 2
    
    [base_score + (symptom_boost * 0.5) + behavior_penalty, 10].min
  end
  
  private
  
  def end_time_after_start_time
    return unless end_time && start_time
    errors.add(:end_time, 'must be after start time') if end_time < start_time
  end
end
