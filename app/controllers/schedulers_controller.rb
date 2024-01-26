class SchedulersController < ApplicationController
  include SchedulersHelper
  include ApplicationHelper
  require 'will_paginate/array'

  def index
    if can?(:scheduler,:search)
      get_search_defaults
      initialize_scheduler
      # Filtering and sort
      params[:completed] = 0 unless params.has_key?(:completed)
      @schedulers = @current_user.schedulers.filtering(params.slice(:completed, :all_words_search, :sentence_search, :bank_account_id, :scheduler_type_id, :account_id))
      @total_schedulers = @schedulers.count
      @schedulers = @schedulers.order(schedulers_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @schedulers.present?
    else
      # Failed Access
      failed_access('Search Schedulers', 'Search')
    end
  end

  def show
    params[:sort] = 'scheduler_items.created_at' if params[:sort].nil?
    get_search_defaults
    @scheduler = Scheduler.find(params[:id])
    if @scheduler.user == @current_user
      @scheduler_item_new = @scheduler.scheduler_items.new
      @scheduler_item_edit = @scheduler.scheduler_items.where(id:params[:error_id]).first if params[:error_id].present?
      @scheduler_item_edit.assign_attributes(scheduler_item_params) if @scheduler_item_edit.present?
      @items = @scheduler.scheduler_items.includes(:scheduler)
      @total_items = @items.count
      @items = @items.order(schedulers_sort_column + " " + asc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @items.present?
    else
      # Failed Access
      failed_access('View Scheduler', 'Read')
    end

  end

  def create
    if can?(:scheduler,:create)
    @scheduler = Scheduler.new(scheduler_params.merge(:user_id => @current_user.id))
      if @scheduler.save
        # Recreate Custom and CRUD Rules
        redirect_link = schedulers_path(updated_id:@scheduler.id)
        flash[:notice] = 'Scheduler Bill successfully created.'
      else
        # Save Failed
        redirect_link = schedulers_path(scheduler:scheduler_params, form_error:'error')
        flash[:error] = errors_to_string(@scheduler.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Bank Account', 'Create')
    end
  end

  def update
   @scheduler = Scheduler.find(params[:id])
     if can?(:scheduler,:update)
      if @scheduler.update(scheduler_params)
        # Recreate Custom and CRUD Rules
        redirect_link = schedulers_path(updated:@scheduler.id)
        flash[:notice] = 'Scheduled Bill successfully updated.'
      else
        # Save Failed
        redirect_link = schedulers_path(:scheduler => scheduler_params, form_error:'error')
        flash[:error] = errors_to_string(@scheduler.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Scheduler', 'Update', @scheduler.id)
    end
  end

  def pay
    @scheduler = Scheduler.find(params[:scheduler_id])
    @item = SchedulerItem.find(params[:item_id])
    if @item.pay
      @scheduler.check_for_completion
      flash[:notice] = 'Scheduled Bill successfully paid.'
    else
      # Save Failed
      flash[:error] = errors_to_string(@item.payment.errors)
    end
    redirect_to params[:from] == 'dashboard' ? dashboard_path : @scheduler
  end

  # Routed Action - Destroy Account
  def destroy
    # Get SubCategory
    @scheduler = Scheduler.find(params[:id])
    if @scheduler.user == @current_user
      # Save Attempt and Log
      if @scheduler.destroy
        access_log("Scheduler", 'Delete')
        flash[:notice] = "Scheduled Bill successfully deleted."
      else
        # Save Failed
        flash[:error] = errors_to_string(@sub_category.errors)
      end
      redirect_to schedulers_path
    else
      # Failed Access
      failed_access("Delete Scheduler", 'Delete', @sub_category.name)
    end
  end

  def create_item
    @scheduler = Scheduler.find(params[:scheduler_id])
    if @scheduler.scheduler_items.create(scheduler_item_params)
      flash[:notice] = "New Bill successfully created."
    else
      flash[:error] = "Error"
    end
      redirect_to @scheduler
  end

  def update_item
    @item = SchedulerItem.find(params[:item_id])
    if can?(:scheduler,:update)
      if @item.update(scheduler_item_params)
        # Recreate Custom and CRUD Rules
        redirect_link = scheduler_path(@item.scheduler_id, updated:@item.id)
        flash[:notice] = 'Scheduled Bill successfully updated.'
      else
        # Save Failed
        redirect_link = scheduler_path(:id => params[:scheduler_item][:scheduler_id], form_error:'error')
        flash[:error] = errors_to_string(@scheduler.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Create Scheduler', 'Update', @scheduler.id)
    end
  end

  def delete_item
    @item = SchedulerItem.find(params[:item_id])
    @scheduler = @item.scheduler
    if can?(:scheduler,:delete)
      if @item.destroy
        flash[:notice] = 'Scheduled Bill successfully deleted.'
      else
        # Save Failed
        flash[:error] = errors_to_string(@item.errors)
      end
      redirect_to redirect_link
    else
      # Failed Access
      failed_access('Delete Scheduler', 'Delete', @scheduler.id)
    end
  end

  # Load In-line Form for when ID present
  def initialize_scheduler
    # Edit Scheduler
    if params[:edit_form_id].present?
      @scheduler = Scheduler.find(params[:edit_form_id])
      @scheduler.assign_attributes(scheduler_params) if params[:scheduler].present?
    # New Scheduler
    else
      @scheduler = params[:scheduler].present? ? @current_user.schedulers.new(scheduler_params) : @current_user.schedulers.new(transaction_type_id:params[:transaction_type_id])
    end
    @bank_accounts = @current_user.bank_accounts
    @accounts_options = accounts_options
    # Transfers
    if params[:transaction_type_id] == '1' || @scheduler.try(:transaction_type_id) == 1
      @sub_categories = @current_user.sub_categories.where(name:'Transfers').map{|l| [l.name, l.category.name, l.id]}.group_by { |c| c[1] }
    # Deposits
    elsif params[:transaction_type_id] == '2' || @scheduler.try(:transaction_type_id) == 2
      @sub_categories = categories_options('deposits')
    # Expenses
    elsif params[:transaction_type_id] ==  '3' || @scheduler.try(:transaction_type_id) == 3
      @sub_categories = categories_options('expenses')
    # All
    else
      @sub_categories = categories_options
    end
  end

  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Bank Accounts").first.id, action:action, access_rule:rule, details:details)
  end

  def scheduler_params
    params.require(:scheduler).permit(:id, :user_id, :scheduler_type_id, :bank_account_id, :account_id, :split, :scheduler_period_id, :description, :amount, :sub_category_id, :last_payment, :transaction_type_id, :created_at, :updated_at)
  end

  def scheduler_item_params
    params.require(:scheduler_item).permit(:created_at,:amount)
  end

end
