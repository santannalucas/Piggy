class Api::V1::UsersController < Api::V1::BaseController

  def index
    if can?(:user,:search)
      @users = User.all
      render json: @users
    else
      render json: {'error':'Unauthorized'}, status: :unauthorized
    end
  end


  def navbar
    render json: {user:@current_user.try(:api_user_data), initials: @current_user.initials}
  end

end