class BehaviorReaction < ApplicationRecord
  belongs_to :emotional_episode
  
  validates :action_type, presence: true, inclusion: { 
    in: ['avoidance', 'confrontation', 'withdrawal', 'seeking_help', 
         'self_harm', 'substance_use', 'exercise', 'meditation', 
         'social_interaction', 'isolation', 'other'] 
  }
  validates :description, length: { maximum: 500 }
  validates :duration_minutes, numericality: { greater_than: 0 }, allow_nil: true
  
  scope :positive_reactions, -> { where(action_type: ['exercise', 'meditation', 'seeking_help', 'social_interaction']) }
  scope :negative_reactions, -> { where(action_type: ['avoidance', 'withdrawal', 'self_harm', 'substance_use', 'isolation']) }
  scope :by_type, ->(type) { where(action_type: type) }
  
  def positive_reaction?
    ['exercise', 'meditation', 'seeking_help', 'social_interaction'].include?(action_type)
  end
  
  def needs_attention?
    ['self_harm', 'substance_use'].include?(action_type)
  end
end