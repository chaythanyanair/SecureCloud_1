class SessionsController < ApplicationController
  def index
    @user=User.all
  end
	def new #login page
	end
	def create #authenticating the login
  		@user = User.find_by_email(params[:session][:email])
  		if @user && @user.authenticate(params[:session][:password])
    			session[:user_id] = @user.id #creating a new session
    			if @user.tpa
    				redirect_to tpa_index_path
    			else
                @user[:online] =  true
                @user.save
          			#redirect_to :action 'users#show', id: @user.id
          			redirect_to current_user
          end
    	else
        flash[:danger] = 'Invalid email/password combination' 
        redirect_to '/login' #unsuccessful login
  		end 
	end
  #def show
    #render '/user'
   # @user=User.find(params[:id])
  #end'''
	def destroy  #logout
    @user = User.find(session[:user_id])
    @user[:online] =  false
    @user.save
    session[:user_id]=nil
    redirect_to '/'
  end
  #def redirect #method to redirect the page to user profile
    #  redirect_to action:'show', id: current_user.id
  #end

end
