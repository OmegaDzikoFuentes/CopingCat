class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable,
        :confirmable
    # Devise authentication

  
    # Associations
    has_many :emotional_episodes, dependent: :destroy
    has_many :diary_entries, dependent: :destroy
    has_many :app_usages, dependent: :destroy
    has_many :strategy_usage_logs, dependent: :destroy
    has_many :user_challenges, dependent: :destroy
    has_many :challenges, through: :user_challenges
    has_many :contexts, dependent: :destroy
    has_many :user_goals, dependent: :destroy
    has_many :trigger_patterns, dependent: :destroy
    has_many :prediction_feedbacks, dependent: :destroy
  
    # Cat customization
    belongs_to :cat, optional: true
    has_many :cat_customizations, dependent: :destroy
    has_one :user_cat_customization, dependent: :destroy  # Use the proper class name
    accepts_nested_attributes_for :user_cat_customization

    store_accessor :preferences, :timezone, :lifestyle
  
    # Validations
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :gender, inclusion: { in: ['Male', 'Female', 'Other', ''] }, allow_blank: true
    validates :occupation, length: { maximum: 100 }
    validates :age, numericality: { greater_than: 0 }, allow_nil: true
  
    # Callbacks
    before_create :assign_default_cat

    attribute :timezone, :string
  
    # Wellness methods
    def wellness_score
      recent_episodes = emotional_episodes.where(created_at: 7.days.ago..Time.current)
      return 50 if recent_episodes.empty?
  
      avg_intensity = recent_episodes.average(:intensity)
      strategy_usage = strategy_usage_logs.where(created_at: 7.days.ago..Time.current).count
  
      base_score = 100 - (avg_intensity * 10)
      usage_bonus = [strategy_usage * 2, 20].min
  
      [base_score + usage_bonus, 100].min.round
    end
  
    def current_streak
      return 0 unless app_usages.any?
  
      streak = 0
      date = Date.current
  
      while app_usages.where(created_at: date.beginning_of_day..date.end_of_day).exists?
        streak += 1
        date = date.yesterday
      end
  
      streak
    end
  
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
      selected_cat = Cat.order("RANDOM()").first || create_default_cat
      update(cat_model: selected_cat.model_filename)
    end
  
    def current_cat_config
      user_cat_customization || build_user_cat_customization
    end

    def self.create_default_cat
      Cat.find_or_create_by(name: "Default Cat") do |cat|
        cat.model_filename = "default_cat.glb"
        cat.category = "basic"
        cat.customizable = false
      end
    end
  

    private
  
    def assign_default_cat
      # Create a default cat customization if none exists
      unless user_cat_customization.present?
        default_cat = Cat.random_cat
        create_user_cat_customization(
          cat: default_cat,
          base_color: '#FF8c42',
          accent_color: '#764ba2',
          accessory: 'none',
          texture: 'smooth'
        )
      end
    end
  end
  