class Api::V1::SchedulersController < Api::V1::BaseController
  include SchedulersHelper
  include ApplicationHelper

  def index
    @schedulers = @current_user.schedulers
    render json:  @schedulers, include:[:scheduler_type, :scheduler_period, :bank_account, :account]
  end

end