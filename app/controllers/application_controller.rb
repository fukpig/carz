class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "devise/sessions#new", :alert => exception.message
  end
  
  layout :layout

  def docs
   render layout: false
  end

  def check_user_fields
    @user = current_user
    fields = ['company_name', 'company_phone', 'phone', 'dealer_number', 'dealer_solution_number']
    empty_field = false
    fields.each do |field|
      if  @user[field].nil? || @user[field].empty?
        empty_field = true
      end
    end
    flash[:alert] = "Please update account."
    redirect_to edit_user_registration_path if empty_field == true
  end

  def check_subscription_status
   redirect_to '/subscriptions/new' if current_user.subscription.nil? && current_user.role != 'admin'
  end

  private
	# Overwriting the sign_out redirect path method
   def after_sign_up_path_for(resource)
    cars_path
   end
  
   def after_sign_in_path_for(resource)
    cars_path
   end

  protected

  def layout
    # only turn it off for login pages:
    if devise_controller? && params[:action] != "edit"
      "head"
	  else
      "application"
    end
  end
  

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
	devise_parameter_sanitizer.for(:sign_up) << :company_name
	devise_parameter_sanitizer.for(:sign_up) << :company_phone
	devise_parameter_sanitizer.for(:sign_up) << :phone
	devise_parameter_sanitizer.for(:sign_up) << :dealer_number
	devise_parameter_sanitizer.for(:sign_up) << :dealer_solution_number
  end

end
