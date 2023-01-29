class ReportsController < ApplicationController
  include ReportsHelper
  require 'will_paginate/array'

  def index
    get_search_defaults(15)
    @reports = Report.all
    @total_reports = @reports.count
    @reports = @reports.order(reports_sort_column + " " + desc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @reports.present?
  end

  def show


    load_sidebar_params
    start = Time.new(params[:year].try(:to_i), params[:month].try(:to_i)).beginning_of_month
    finish = Time.new(params[:end_year].try(:to_i), params[:end_month].try(:to_i)).end_of_month

    @report = Report.where(id:params[:id])
    @report = @report.first if @report.present?
    @bank_account = BankAccount.find(params[:account_id]||@current_user.bank_account.id)

    case @report.try(:name)
    when "Monthly Result per Year"
      @monthly_result = @current_user.transactions.bank_account_id(@bank_account.id).no_transfers.monthly_results(@current_user,params[:year], 1)
      @colors = values_to_colors(@monthly_result.collect{|x| x[1]})
    when "Total Balance"
      @balance = @current_user.total_balance(start,finish,params[:period],params[:bank_account_id] )
    when "Categories by Period"
      params[:cat_type] = :expenses if params[:cat_type].nil?
      @categories = @current_user.categories_on_period(start,finish, params[:bank_account_id])[params[:cat_type].to_sym].sort_by {|x| -x[1]}
    else
      flash[:error] = "Report Not found"
      redirect_back(fallback_location: reports_path)
     end
  end

  private # Controller Private Methods

  def load_sidebar_params
    params[:year] = Time.now.year if params[:year].nil?
    params[:month] = 1 if params[:month].nil?
    params[:period] = 'year' if params[:period].nil?
    params[:end_year] = Time.now.year if params[:end_year].nil?
    params[:end_month] = 12 if params[:end_month].nil?
  end

  # Access Log
  def access_log(action, rule, details = nil)
    AccessLog.create(user_id: @current_user.id , role_id: @current_user.role.id, workspace_id: Workspace.where(name:"Bank Accounts").first.id, action:action, access_rule:rule, details:details)
  end

end
