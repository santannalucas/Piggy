class Api::V1::Admin::RolesController < Api::V1::BaseController
  before_action :authenticate_api
  skip_before_action :logged_in_user

  def index
    if can?(:role, :read)
      @roles = Role.all.collect{|x| [x.id, x.name}
      render json: @roles
    end
  end

end