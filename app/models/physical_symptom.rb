class PhysicalSymptom < ApplicationRecord
  belongs_to :emotional_episode
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :severity, numericality: { in: 1..10 }, allow_nil: true
  
  scope :severe, -> { where(severity: 8..10) }
  scope :moderate, -> { where(severity: 4..7) }
  scope :mild, -> { where(severity: 1..3) }
  scope :by_name, ->(name) { where(name: name) }
  
  # Common physical symptoms
  COMMON_SYMPTOMS = [
    'Heart racing', 'Tight chest', 'Trembling', 'Sweaty palms',
    'Headache', 'Muscle tension', 'Nausea', 'Dizziness',
    'Shortness of breath', 'Fatigue', 'Restlessness'
  ].freeze
  
  def severity_level
    case severity
    when 1..3
      'mild'
    when 4..7
      'moderate'
    when 8..10
      'severe'
    end
  end
end