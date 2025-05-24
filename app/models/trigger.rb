class Trigger < ApplicationRecord
    has_many :emotional_episodes
    has_many :trigger_patterns
    has_many :user_goals, foreign_key: 'target_trigger_id'
    has_many :episode_trigger_intensities
    has_many :prediction_feedbacks, foreign_key: 'predicted_trigger_id'
    
    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
    validates :category, length: { maximum: 50 }
    validates :trigger_type, inclusion: { in: ['internal', 'external'] }
    
    scope :by_category, ->(category) { where(category: category) }
    scope :internal, -> { where(trigger_type: 'internal') }
    scope :external, -> { where(trigger_type: 'external') }
    scope :social, -> { where(category: 'Social') }
    scope :environmental, -> { where(category: 'Environmental') }
    scope :cognitive, -> { where(category: 'Cognitive') }
    
    def frequency_for_user(user)
      emotional_episodes.where(user: user).count
    end
    
    def average_intensity_for_user(user)
      episodes = emotional_episodes.where(user: user)
      episodes.average(:intensity)&.round(2) || 0
    end
end