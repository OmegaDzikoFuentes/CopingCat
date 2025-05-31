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

  before_validation :normalize_values

  # Relationship with original cat model if needed
  def base_cat_model
    cat&.model_filename || 'default_cat.glb'
  end

  private

  def normalize_values
    self.accessory = normalize_accessory(accessory)
    self.texture = normalize_texture(texture)
  end

  def normalize_accessory(value)
    return '' if value.blank?
    
    case value.downcase
    when 'bowtie' then 'bowtie'
    when 'collar' then 'collar'
    when 'hat' then 'hat'
    when 'glasses' then 'glasses'
    else ''
    end
  end

  def normalize_texture(value)
    return '' if value.blank?
    
    case value.downcase
    when 'smooth', 'sleek' then 'sleek'  # Map "Smooth" to "sleek"
    when 'fluffy' then 'fluffy'
    when 'striped' then 'striped'
    when 'spotted' then 'spotted'
    else ''
    end
  end
  
end
