class Api::V1::BaseController < ApplicationController
  before_action :authenticate_api
  skip_before_action :logged_in_user
end