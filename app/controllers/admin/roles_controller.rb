class Admin::RolesController < ApplicationController
  # Helpers and Modules
  include AccessRulesHelper
  require 'will_paginate/array'

  # Routed Action - Role Show (Users, Access Rules and Custom Rules)
  def show
    # Get or Reload other Role (Search params[:role_id])
    if params[:role_id].present? && params[:role_id] != params[:id]
      redirect_to role_path(:id => params[:role_id], :role_id => nil, :show => params[:show])
    else
      @role = Role.find(params[:id])
      params[:show] = 'users' if params[:show].nil?
      # Check Access
      if can?(:role,:read)
        # Get Search default params and Log
        get_search_defaults
        access_log("View Role #{params[:show].titleize}", 'Read', @role.name)
        # Show Users
        if params[:show] == 'users' && can?(:user,:read)
          @showing = @role.users.active.filtering(params.slice(:sentence_search, :all_words_search))
          @user = User.new
          # Show Access Rules
        elsif params[:show] == 'rules' && can?(:rule,:read)
          @showing = @role.rules.joins(:workspace).filtering(params.slice(:sentence_search, :all_words_search))
          # Show Access Rules
        elsif params[:show] == 'custom_rules' && can?(:custom_rule,:read)
          @showing = @role.custom_role_rules.joins(:custom_rule).filtering(params.slice(:status,:workspace_id,:sentence_search, :all_words_search))
          @avail_rules = CustomRule.filtering(params.slice(:workspace_id)).not_assigned(@role.id).collect {|x| [x.description,x.id]}
          @new_custom = CustomRoleRule.new
        end
        # Sorting and Pagination
        @showing = @showing.order(sort_rules_column + " " + asc_sort_direction).uniq
        @total_showing = @showing.count
        @showing = @showing.paginate(:page => params[:page], :per_page => params[:per_page]) if @showing.present?
        render 'admin/rules/role'
      else
        # Failed Access
        failed_access("View Role #{params[:show].titleize}", 'Read', @role.name)
      end
    end
  end

  # Routed Action - Create Role
  def create
    # Check Access
    if can?(:role, :create)
      @role = Role.new(role_params)
      # Save Attempt and Log
      if @role.save
        # Recreate Custom and CRUD Rules
        Role.rebuild
        redirect_link = role_path(:id => @role.id)
        access_log('Create Role', 'Create', @role.summary_info)
        flash[:notice] = 'Role successfully created.'
      else
        # Save Failed
        redirect_link = rules_path(:show => 'roles', :errors => 'found', :new_name => @role.try(:name))
        flash[:error] = errors_to_string(@role.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Role', 'Create', role_params)
    end
  end

  # Routed Action - Update Role
  def update
    @role = Role.find(params[:id])
    # Check Access
    if can?(:role, :update)
      # Save Attempt
      if @role.update(role_params)
        access_log('Role Update','Update', @role.summary_info)
        flash[:notice] = 'Role successfully updated.'
        redirect_link =  rules_path(:show => 'roles', :updated => @role.id, :anchor => "field_record_#{@role.id}")
      else
        # Save Failed
        flash[:error] = errors_to_string(@role.errors)
        redirect_link =  rules_path(:show => 'roles', :name => @role.try(:name), :error_id => params[:id])
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Update Role', 'Update', role_params)
    end
  end

  private # Controller Private Methods

  # Role Secure Params
  def role_params
    params.require(:role).permit(:name,:ad_dn)
  end

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Roles").first.id, action:action, access_rule:rule, details:details)
  end

end