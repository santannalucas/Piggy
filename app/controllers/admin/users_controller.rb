class Admin::UsersController < ApplicationController
  # Helpers and Modules
  helper AccessRulesHelper
  require 'will_paginate/array'


  # Routed Action - Search Users
  def index
    # Check Access and Logs
    if can?(:user, :search)
      access_log('Search Users','Search')
      # Get Search default params
      get_search_defaults(15)
      params[:status] = 1 unless params.has_key?(:status)
      @users = User.all
      @user = User.new
      # Filtering and Search
      @users = @users.joins(:role).status(params[:status]).filtering(params.slice(:role_id, :sentence_search, :all_words_search))
      # Sorting and Pagination
      @showing = @users.order(sort_rules_column + " " + asc_sort_direction).uniq
      @total_showing = @users.count
      @showing = @showing.uniq.paginate(:page => params[:page], :per_page => params[:per_page]) if @showing.present?
    else
      # Failed Access
      failed_access('Search Users','Search')
    end
  end

  # Routed Action - Show User
  def show
    # Find User
    @user = User.find(params[:id])
    # Check Access and Log
    if can?(:user, :read) || @user == @current_user
      access_log('View User','Read', @user.name)
    else
      # Failed Access
      failed_access('View User', 'Read', @user.name)
    end
  end

  def create
    if can?(:bank_account,:create)
      @user = User.new(user_params.merge(:password => SecureRandom.base64(10),:active => true))
      if @user.save
        @user.validate_options
        # Recreate Custom and CRUD Rules
        redirect_link = user_path(@user)
        flash[:notice] = 'User successfully created.'
      else
        # Save Failed
        redirect_link = users_path(user:user_params, errors:'error')
        flash[:error] = errors_to_string(@user.errors)
      end
      redirect_to @user
    else
      # Failed Access
      failed_access('Create User', 'Create')
    end
  end

  # Router Action - Update User (Default Dashboard only)
  def update
    @user = User.find(params[:id])
    # Check Access
    if can?(:user, :update) || @user == @current_user
      # Save Attempt and Log
      @user.assign_attributes(user_params)
      @user.options = params[:options]
      if @user.save
        access_log('Update User','Update', user_params)
        flash[:notice] = "User successfully updated."
        redirect_to user_path(:from => params[:from])
      else
        # Save Failed
        redirect_back(fallback_location: user_path(:from => params[:from]))
        flash[:error] = errors_to_string(@user.errors)
      end
    else
      # Failed Access
      failed_access('Update User','Update', user_params)
    end
  end

  private # Controller Private Methods

  # User Secure Params
  def user_params
    params.require(:user).permit(:name, :email, :password, :role_id, :options)
  end

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: current_user.id , role_id: current_user.role.id, workspace_id: Workspace.where(name:"Users").first.id, action:action, access_rule:rule, details:details)
  end

end
