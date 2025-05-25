class User < ApplicationRecord
    has_many :diary_entries, dependent: :destroy
    has_many :emotional_episodes, dependent: :destroy
    has_many :contexts, dependent: :destroy
    has_many :trigger_patterns, dependent: :destroy
    has_many :user_goals, dependent: :destroy
    has_many :app_usages, dependent: :destroy
    has_many :prediction_feedbacks, dependent: :destroy
    has_one :cat_customization, class_name: 'UserCatCustomization', dependent: :destroy
    accepts_nested_attributes_for :cat_customization
    
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :name, length: { maximum: 100 }
    validates :gender, inclusion: { in: ['Male', 'Female', 'Other', ''] }, allow_blank: true
    validates :occupation, length: { maximum: 100 }
    validates :age, numericality: { greater_than: 0 }, allow_nil: true
    
    # Serialize lifestyle as JSON if using PostgreSQL jsonb or text field
    serialize :lifestyle, JSON if column_names.include?('lifestyle')
    
    # Analytics methods
    def engagement_score(date = Date.current)
      AppUsage.daily_engagement_score(self, date)
    end
    
    def active_goals_count
      user_goals.active_goals.count
    end
    
    def prediction_accuracy
      PredictionFeedback.accuracy_rate(self)
    end

    def assign_random_cat
        update(cat_model: Cat.random_cat.model_filename)
    end

    def current_cat_config
        cat_customization || create_cat_customization
    end
    
  end