class RegistrationsController < Devise::RegistrationsController
  def create
    super
    flash[:new_user] = true
  end
  
  protected

  def after_sign_up_path_for(resource)
    integrations_path
  end
end