class CopingStrategy < ApplicationRecord
    has_many :episode_coping_strategies, dependent: :destroy
    has_many :emotional_episodes, through: :episode_coping_strategies
    has_many :strategy_usage_logs, dependent: :destroy
    has_many :users, through: :strategy_usage_logs
  
    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
    validates :category, length: { maximum: 50 }, allow_nil: true
    validates :instructions, presence: true
    validates :emotion_category, presence: true
    validates :difficulty_level, inclusion: { in: 1..5 }
  
    scope :by_category, ->(category) { where(category: category) }
    scope :relaxation, -> { where(category: 'Relaxation') }
    scope :exercise, -> { where(category: 'Exercise') }
    scope :social, -> { where(category: 'Social') }
    scope :for_emotion, ->(emotion) { where(emotion_category: emotion) }
    scope :by_difficulty, ->(level) { where('difficulty_level <= ?', level) }
    scope :most_effective, -> {
      joins(:strategy_usage_logs)
        .group('coping_strategies.id')
        .order('AVG(strategy_usage_logs.effectiveness_rating) DESC')
    }
  
    def average_effectiveness
      strategy_usage_logs.average(:effectiveness_rating) || 0
    end
  
    def usage_count
      strategy_usage_logs.count
    end
  end