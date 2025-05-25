class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    super do |user|
      # Assign random cat if not customizing
      user.build_cat_customization unless user.cat_customization
      user.assign_random_cat if user.persisted?
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      cat_customization_attributes: [
        :base_color, 
        :accent_color, 
        :accessory, 
        :texture,
        :cat_id  # If selecting from predefined base models
      ]
    ])
  end
end
