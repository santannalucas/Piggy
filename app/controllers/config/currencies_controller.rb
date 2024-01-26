class Config::CurrenciesController < ApplicationController
  # Helpers and Modules
  include CurrenciesHelper
  require 'will_paginate/array'

  ### Currency(ies) - Routes / Controller Methods

  # Routed Action - Currencies Index
  def index
    # Check Access and Log
    if can?(:currency,:search)  # Index
      get_search_defaults
      access_log('Search Currencies', 'Search')
      # Form for New / Edit Currency
      @currency_new = @current_user.currencies.new
      @currency_edit = Currency.find(params[:error_id]).assign_attributes(currency_params) if params[:error_id].present?
      # Filtering and sort Users
      @currencies = @current_user.currencies.filtering(params.slice(:all_words_search, :sentence_search))
      @total_currencies = @currencies.count
      @currencies = @currencies.order(currencies_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @currencies.present?
    else
      # Failed Access
      failed_access('Search Currencies', 'Search')
    end
  end

  def create
    if can?(:currency,:create)
      @currency = @current_user.currencies.new(currency_params)
      if @currency.save
        # Recreate Custom and CRUD Rules
        redirect_link = currencies_path
        flash[:notice] = 'Currency successfully created.'
      else
        # Save Failed
        redirect_link = currencies_path(currency:currency_params, errors:'error')
        flash[:error] = errors_to_string(@currency.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Currency', 'Create')
    end
  end

  # Routed Action - Update Account
  def update
    @currency = Currency.find(params[:id])
    # Check Access and Log
    if can?(:currency, :update)
      if @currency.update(currency_params)
        access_log('Update Currency', 'Update', @currency.name)
        flash[:notice] = "Currency successfully updated."
        redirect_link =  currencies_path(:updated => @currency.id, :anchor => "field_record_#{@currency.id}")
      else
        flash[:error] = errors_to_string(@currency.errors)
        redirect_link =  currencies_path(:name => @currency.try(:name), :error_id => params[:id])
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access("Update Currency", 'Update', currency_params)
    end
  end

  # Routed Action - Destroy Account
  def destroy
    # Get Account and Action Type
    @account = Account.find(params[:id])
    action_type = @account.deleted_at.nil? ? 'delete' : 'restore'
    # Check Access
    if can?(:account, :delete)
      # Change/Toggle deleted at field
      @account.deleted_at.nil? ? @account.deleted_at = Time.now : @account.deleted_at = nil
      # Save Attempt and Log
      if @account.save
        # Remove Users if Deactivated
        @account.users.each do |user| user.update_column(:account_id, nil) end if @account.deleted_at.present?
        access_log("#{action_type.titleize} Account", 'Delete', @account.name)
        flash[:notice] = "Account #{@account.name} successfully #{action_type}d."
        return_url = accounts_path
      else
        # Save Failed
        flash[:error] = errors_to_string(@account.errors)
        return_url = account_path(@account)
      end
      redirect_to return_url
    else
      # Failed Access
      failed_access("#{action_type.titleize} Account", 'Delete', @account.name)
    end
  end



  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Accounts").first.id, action:action, access_rule:rule, details:details)
  end

  # Account Secure Params
  def currency_params
    params.require(:currency).permit(:name, :code, :rate)
  end

end