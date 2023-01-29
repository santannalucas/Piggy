module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

 # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    # @logs = Log.create(user_id: current_user.id, role_id: current_user.role_id, action:"Logoff")
    @current_user = nil
  end

# Redirects to stored Location (or to the default)
def redirect_back_or(default)
	redirect_to(session[:forwarding_url] || default)
	session.delete(:forwarding_url)
end

def store_location
     session[:forwarding_url] = request.url if request.get?
end 
   
	#Redirect_to_back
	  def go_back
	    #Attempt to redirect
	    redirect_to :back
		return
 
	    #Catch exception and redirect to root
	    rescue ActionController::RedirectBackError
	      redirect_to root_path
	   end

	



end
