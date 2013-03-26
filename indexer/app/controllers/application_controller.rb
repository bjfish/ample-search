class ApplicationController < ActionController::Base
  check_authorization :unless => :admin_controller?
  before_filter :set_user_time_zone
  #before_filter :set_locale
  
  def admin_controller?
    self.kind_of?(ActiveAdmin::BaseController) || self.kind_of?(ActiveAdmin::Devise::SessionsController) || self.devise_controller?
  end

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def set_user_time_zone
    Time.zone = current_user.time_zone if user_signed_in?
  end
  
  private


  
   def set_locale   
        available = sanitize_available_locales #I18n.available_locales         
        I18n.locale = http_accept_language.compatible_language_from(available)  || I18n.default_locale
   end  

end
