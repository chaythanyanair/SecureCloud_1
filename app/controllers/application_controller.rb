class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user	

	def current_user #check if current user's session id is registered
  		@current_user ||= User.find(session[:user_id]) if session[:user_id] 
	end
	def require_user # checking if user is logged in before redirecting to direct links
  		redirect_to '/sessions/new' unless current_user 
	end
  def correct_user
    @user=User.find(params[:id])
    redirect_to(root_url) unless @user==current_user
  end  
	
include SimpleCaptcha::ControllerHelpers

end
