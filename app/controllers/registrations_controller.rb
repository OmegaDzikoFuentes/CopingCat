class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    super do |user|
      if user.persisted?
        # User was successfully created, cat will be assigned via callback
        # Send welcome message or perform other setup
        Rails.logger.info "New user #{user.email} registered with cat: #{user.user_cat_customization&.cat&.name}"
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name, :age, :gender, :occupation, :timezone, :lifestyle,
      user_cat_customization_attributes: [:base_color, :accent_color, :accessory, :texture, :cat_id]
    ])
  end

  # Redirect after successful registration
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end