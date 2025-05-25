class UserCatCustomization < ApplicationRecord
  belongs_to :user
  belongs_to :cat, optional: true  # If using predefined base models
  
  # Basic customization attributes
  validates :base_color, format: { with: /\A#[a-f0-9]{6}\z/i }, allow_blank: true
  validates :accent_color, format: { with: /\A#[a-f0-9]{6}\z/i }, allow_blank: true
  validates :accessory, inclusion: { in: ['bowtie', 'collar', 'hat', 'glasses', ''] }, allow_blank: true
  validates :texture, inclusion: { in: ['fluffy', 'sleek', 'striped', 'spotted', ''] }, allow_blank: true

  # For more complex customization
  serialize :customizations, JSON

  # Relationship with original cat model if needed
  def base_cat_model
    cat&.model_filename || 'default_cat.glb'
  end
end
