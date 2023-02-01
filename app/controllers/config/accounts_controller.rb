class Config::AccountsController < ApplicationController
  # Helpers and Modules
  include AccountsHelper
  require 'will_paginate/array'

  # Routed Actions organized by:
  # Account(s)
  # Users
  # Tags

  ### Account(s) - Routes / Controller Methods

  # Routed Action - Account Index
  def index
    # Check Access and Log
    if can?(:account,:search)  # Index
      get_search_defaults(15)
      access_log('Search Accounts', 'Search')
      # Form for New Account
      @account_new = @current_user.accounts.new
      @account_edit = Account.find(params[:error_id]) if params[:error_id].present?
      @account_edit.assign_attributes(account_params) if @account_edit.present?
      # Filtering and sort Users
      @accounts = @current_user.accounts.filtering(params.slice(:all_words_search, :sentence_search))
      @total_accounts = @accounts.count
      @accounts = @accounts.order(accounts_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @accounts.present?
    else
      # Failed Access
      failed_access('Search Accounts', 'Search')
    end
  end

  # Routed Action - Create Account
  def create
    # Check Access and Log
    if can?(:account,:create)
      @account = @current_user.accounts.new(account_params)
      if @account.save
        # Recreate Custom and CRUD Rules
        redirect_link = accounts_path
        flash[:notice] = 'Account successfully created.'
      else
        # Save Failed
        redirect_link = accounts_path(account:account_params, errors:'error')
        flash[:error] = errors_to_string(@account.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Account', 'Create')
    end
  end

  # Routed Action - Update Account
  def update
    @account = Account.find(params[:id])
    if can?(:account,:update)
      if @account.update(account_params)
        # Recreate Custom and CRUD Rules
        redirect_link = accounts_path(updated:@account.id)
        flash[:notice] = 'Account successfully updated.'
      else
        # Save Failed
        redirect_link = accounts_path(account:account_params, error_id:@account.id)
        flash[:error] = errors_to_string(@account.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Account', 'Create', @account.name)
    end
  end

  # Routed Action - Destroy Account
  def destroy
    # Get Account and Action Type
    @account = Account.find(params[:id])
    account_name = @account.name
    if can?(:account, :delete)
      # Save Attempt and Log
      if @account.destroy
        access_log("Account", 'Delete', account_name)
        flash[:notice] = "Account successfully deleted."
        return_url = accounts_path
      else
        # Save Failed
        flash[:error] = errors_to_string(@account.errors)
        return_url = accounts_path
      end
      redirect_to return_url
    else
      # Failed Access
      failed_access("Delete Account", 'Delete', @account.name)
    end
  end



  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Accounts").first.id, action:action, access_rule:rule, details:details)
  end

  # Account Secure Params
  def account_params
    params.require(:account).permit(:name, :description)
  end

end