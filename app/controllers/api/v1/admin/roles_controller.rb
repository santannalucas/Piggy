class Api::V1::Admin::RolesController < Api::V1::BaseController

  def index
      @roles = Role.all.collect{|x| [x.id, x.name]}
      render json: @roles
  end

end