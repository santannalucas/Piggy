class Admin::RulesController < ApplicationController
  # Helpers and Modules

  include AccessRulesHelper
  require 'will_paginate/array'

  # Routed Action -  Access Rules Indexes (Role, Workspaces and Custom Rules)
  def index
    # Showing
    params[:show] = get_user_admin_rules.first || 'Roles' if params[:show].nil?
    # Check Access
    if can?(:role, :search) || can?(:workspace, :search) || can?(:custom_rule, :search) || can?(:rule, :search)
      get_search_defaults
      # Show Roles
      if params[:show] == 'roles' && can?(:rule,:search)
        show_roles
      # Show Workspaces
      elsif params[:show] == 'workspaces' && can?(:rule,:search)
        show_workspaces
      # Show Custom Rules
      elsif params[:show] == 'custom_rules' && can?(:rule,:search)
        show_custom_rules
      end
      # Pagination
      @total_showing = @showing.count
      @showing = @showing.paginate(:page => params[:page], :per_page => params[:per_page]) if @showing.present?
    else
      # Failed Access
      failed_access("Search #{params[:show].try(:titleize)}",'Search')
    end
  end

  # Routed Action - Update Access Rules
  def update
    @rule = Rule.find(params[:rule][:id])
    # Check Access
    if can?(:rule, :update)
      # Save Attempt and Log
      if @rule.update(rule_params)
        access_log('Update Rule','Update', [@rule.role.name, @rule.workspace.name].join(' - '))
        redirect_to role_path(@rule.role.id, :show => 'rules', :page => params[:page], :per_page => params[:per_page], :updated => @rule.id, :anchor => "field_record_#{@rule.id}")
        flash[:notice] = "Rule successfully updated."
      else
        # Save Failed
        redirect_to role_path(@rule.role.id, :show => 'rules')
        flash[:error] = errors_to_string(@rule.errors)
      end
    else
      # Failed Access
      failed_access('Update Rule','Update', rule_params)
    end
  end

  # Routed Action - Show Role (Users, Access Rules and Custom Rules)
  def workspace
   # Get or Reload other Workspace (Search params[:workspace_id])
   params[:id] = params[:workspace_id] if params[:workspace_id]
   @workspace = Workspace.find(params[:id])
    params[:show] = 'rules' if params[:show].nil?
    # Check Access and Log
    if can?(:workspace,:read)
      get_search_defaults
      access_log("View Workspace #{params[:show].titleize}", 'Read', @workspace.name)
      # Show Rules
      if params[:show] == 'rules' && can?(:rule,:read)
        @showing = @workspace.rules.joins(:role)
      # Show Custom Rules
      elsif params[:show] == 'custom_rules' && can?(:custom_rule,:read)
        @showing = @workspace.custom_role_rules.joins(:custom_rule, :role)
      end
      # Search, Sort & Pagination
      @showing = @showing.filtering(params.slice(:role_id, :status, :sentence_search, :all_words_search))
      @showing = @showing.order(sort_rules_column + " " + asc_sort_direction).uniq
      @total_showing = @showing.count
      @showing = @showing.paginate(:page => params[:page], :per_page => params[:per_page]) if @showing.present?
    else
      # Failed Access
      failed_access("View Workspace #{params[:show].titleize}", 'Read', @workspace.name)
    end
  end

  # Routed Action - Create Custom Role Rule
  def create_role_custom
    # Check Access
    if can?(:custom_rule, :create)
      @custom_role_rule = CustomRoleRule.new(custom_role_rule_params)
      # Save Attempt and Log
      if @custom_role_rule.save
        access_log('Create Custom Role Rule','Create', @custom_role_rule.log_details)
        redirect_to role_path(@custom_role_rule.role, :show => 'custom_rules', :page => params[:page], :per_page => params[:per_page], :updated => @custom_role_rule.id, :anchor => @custom_role_rule.id)
        flash[:notice] = "Custom Rule successfully Created."
      else
        # Save Failed
        redirect_to role_path(@custom_role_rule.role, :show => 'custom_rules')
        flash[:error] = errors_to_string(@custom_role_rule.errors)
      end
    else
      # Failed Access
      failed_access('Create Custom Role Rule', 'Create', custom_role_rule_params)
    end
  end

  # Routed Action - Update Custom Rules
  def update_custom
    @custom = CustomRule.find(params[:custom_rule][:id])
    # Check Access
    if can?(:custom_rule, :update)
      # Save Attempt and Log
      if @custom.update(custom_rule_params)
        flash[:notice] = 'Custom Rule successfully updated.'
        access_log('Custom Rule Update','Update', @custom.summary_info)
        redirect_link =  rules_path(:show => 'custom_rules', :updated => @custom.id, :anchor => "field_record_#{@custom.id}")
      else
        # Save Failed
        flash[:error] = errors_to_string(@custom.errors)
        redirect_link =  rules_path(:show => 'custom_rules', :short => @custom.try(:description), :long => @custom.try(:long_description),  :error_id => @custom.id)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Custom Rule Update', 'Update', custom_rule_params)
    end
  end

  # Routed Action - Update Custom Role Rule
  def update_role_custom
    @custom_rule = CustomRoleRule.find(params[:custom_role_rule][:id])
    # Check Access
    if can?(:custom_rule, :update)
      # Save Attempt and Log
      if @custom_rule.update(custom_role_rule_params)
        access_log('Custom Role Rule','Update', [@custom_rule.custom_rule.description, @custom_rule.access.to_s].join(' - '))
        redirect_to role_path(@custom_rule.role.id, :show => 'custom_rules', :page => params[:page], :per_page => params[:per_page], :updated => @custom_rule.id, :anchor => "field_record_#{@custom_rule.id}")
        flash[:notice] = "Custom Rule successfully updated."
      else
        # Save Failed
        redirect_to role_path(@rule.role.id, :show => 'custom_rules')
        flash[:error] = errors_to_string(@rule.errors)
      end
    else
      # Failed Access
      failed_access('Update Custom Rule','Update', custom_role_rule_params)
    end
  end

  ## Controller Methods ##

  # Show Roles Index
  def show_roles
    # Search, Sort & Pagination
    @new_role = Role.new(name: params[:new_name]) if can?(:role,:create)
    @showing = Role.filtering(params.slice(:sentence_search, :all_words_search))
    @showing = @showing.order(sort_rules_column + " " + asc_sort_direction).uniq
    access_log('Search Roles', 'Search') unless params[:error].present? || params[:error_id].present? || params[:updated].present?
  end

  # Show Workspaces Index
  def show_workspaces
    # Search, Sorting & Pagination
    access_log('Search Workspaces', 'Search')
    @showing = Workspace.filtering(params.slice(:workspace_id,:sentence_search, :all_words_search))
    @showing = @showing.order(sort_rules_column + " " + asc_sort_direction).uniq
  end

  # Show Custom Index
  def show_custom_rules
    # Search, Sorting & Pagination
    @showing = CustomRule.joins(:workspace).filtering(params.slice(:workspace_id,:sentence_search, :all_words_search))
    @showing = @showing.order(sort_rules_column + " " + asc_sort_direction).uniq
    access_log('Search Custom Rules', 'Search')
  end

  private # Controller Private Methods

  # Role Secure Params
  def role_params
    params.require(:role).permit(:name,:ad_dn)
  end

  # Rule Params
  def rule_params
    params.require(:rule).permit(:c, :r, :u, :d, :s, :p )
  end

  # Custom Rule Params
  def custom_rule_params
    params.require(:custom_rule).permit(:description, :long_description)
  end

  # Custom Role Rule Params
  def custom_role_rule_params
    params.require(:custom_role_rule).permit(:custom_rule_id, :role_id, :access)
  end

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: current_user.id , role_id: current_user.role.id, workspace_id: Workspace.where(name:"Rules").first.id, action:action, access_rule:rule, details:details)
  end

end
