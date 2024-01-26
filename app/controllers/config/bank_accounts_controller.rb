class Config::BankAccountsController < ApplicationController
  include BankAccountsHelper
  include ApplicationHelper
  require 'will_paginate/array'

  def index
    # Check Access and Log
    if can?(:bank_account,:search)  # Index
      get_search_defaults
      # Form for New Account
      @bank_account_new = @current_user.bank_accounts.new
      @currencies = @current_user.currencies
      @bank_account_edit = BankAccount.find(params[:error_id]) if params[:error_id].present?
      @bank_account_edit.assign_attributes(bank_account_params) if @bank_account_edit.present?
      # Filtering and sort Users
      @bank_accounts = @current_user.bank_accounts.filtering(params.slice(:all_words_search, :sentence_search, :currency_id, :start_date, :end_date))
      @total_bank_accounts = @bank_accounts.count
      @bank_accounts = @bank_accounts.order(bank_acc_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @bank_accounts.present?
    else
      # Failed Access
      failed_access('Search Bank Accounts', 'Search')
    end
  end

  def create
    if can?(:bank_account,:create)
    @bank_account = BankAccount.new(bank_account_params.merge(:user_id => @current_user.id))
      if @bank_account.save
        # Recreate Custom and CRUD Rules
        redirect_link = bank_accounts_path
        flash[:notice] = 'Bank Account successfully created.'
      else
        # Save Failed
        redirect_link = bank_accounts_path(bank_account:bank_account_params, errors:'error')
        flash[:error] = errors_to_string(@bank_account.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Bank Account', 'Create')
    end
  end

  def update
    @bank_account = BankAccount.find(params[:id])
    if can?(:bank_account,:update)
      if @bank_account.update(bank_account_params)
        # Recreate Custom and CRUD Rules
        redirect_link = bank_accounts_path(updated:@bank_account.id)
        flash[:notice] = 'Bank Account successfully updated.'
      else
        # Save Failed
        redirect_link = bank_accounts_path(bank_account:bank_account_params, error_id:@bank_account.id)
        flash[:error] = errors_to_string(@bank_account.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Bank Account', 'Create', @bank_account.name)
    end
  end

  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Bank Accounts").first.id, action:action, access_rule:rule, details:details)
  end

  def bank_account_params
    params.require(:bank_account).permit(:id, :account_type, :currency_id, :dashboard, :active, :name, :number, :description, :created_at, :updated_at,:user_id)
  end
end
