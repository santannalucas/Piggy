class Schedulers::SchedulerItemsController < ApplicationController
  include SchedulersHelper
  include ApplicationHelper
  require 'will_paginate/array'

  def create
    @scheduler = Scheduler.find(params[:scheduler_id])
    if @scheduler.scheduler_items.create(scheduler_item_params)
      flash[:notice] = "New Bill successfully created."
    else
      flash[:error] = "Error"
    end
      redirect_to @scheduler
  end

  def update
    @item = SchedulerItem.find(params[:item_id])
    if can?(:scheduler,:update)
      if @item.update(scheduler_item_params)
        if params[:repeat].present? && @item.scheduler.scheduler_period.present?
          last_date = @item.scheduler.scheduler_items.order(:created_at).last.created_at
          params[:repeat].to_i.times do
            @item = @item.dup
            new_date = Scheduler.increase_date(last_date, @item.scheduler)
            @item.created_at = new_date
            @item.transaction_id = nil
            @item.save
            last_date = new_date
          end
        end
        @item.scheduler.scheduler_items.unpaid.update_all(amount: @item.amount) if params[:apply_all]
        redirect_link = scheduler_path(@item.scheduler_id, updated:@item.id)
        flash[:notice] = 'Scheduled Bill successfully updated.'
      else
        redirect_link = scheduler_path(:id => params[:scheduler_item][:scheduler_id], form_error:'error')
        flash[:error] = errors_to_string(@scheduler.errors)
      end
      @item.scheduler.check_for_completion
      redirect_to redirect_link
    else
      failed_access('Create Scheduler', 'Update', @scheduler.id)
    end
  end

  def destroy
    @item = SchedulerItem.find(params[:item_id])
    @scheduler = @item.scheduler
    if can?(:scheduler,:delete)
      if @item.destroy
        flash[:notice] = 'Scheduled Bill successfully deleted.'
        @scheduler.check_for_completion
      else
        flash[:error] = errors_to_string(@item.errors)
      end
      redirect_back(fallback_location: @scheduler)
    else
      # Failed Access
      failed_access('Delete Scheduler', 'Delete', @scheduler.id)
    end
  end

  private # Controller Private Methods

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Schedulers").first.id, action:action, access_rule:rule, details:details)
  end

  def scheduler_item_params
    params.require(:scheduler_item).permit(:created_at,:amount)
  end
end
