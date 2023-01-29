class SessionsController < ApplicationController
	skip_before_action :logged_in_user, only: [:new, :create]

	def new
		if logged_in?
		redirect_to dashboard_path
		flash.now[:danger] = 'Welcome.'
		else
		render :layout => false	
		end  
	end

	def create
	user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
		log_in user
		params[:session][:remember_me] == '1' ? remember(user) : forget(user)
		#@logs = Log.create(user_id: current_user.id , role_id: current_user.role_id, action:"Login")
		redirect_to dashboard_path
		else 
		flash.now[:danger] = 'Email or Password incorrect.'
		render'new', :layout => false
		end
	end

	def destroy
		log_out if logged_in?
		redirect_to root_url
	end

end
