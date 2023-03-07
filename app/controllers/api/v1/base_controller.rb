class Api::V1::BaseController < ApplicationController
  before_action :authenticate_api
  skip_before_action :logged_in_user

  private

  def authenticate_api
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
    decoded = jwt_decode(header)
    @current_user = User.find(decoded[:user_id])
    rescue => e
      render json: {error:'Expired Session'}, status: :unauthorized
      Rails.logger.info(e)
    end
  end

end