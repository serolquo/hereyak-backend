class PasswordsController < Devise::PasswordsController
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_path
  end
  
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      redirect_to root_path
    end
  end
  
  
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      redirect_to root_path
    else
      respond_with resource
    end
  end
end
