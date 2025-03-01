class TransactionsController < ApplicationController
  include TransactionsHelper
  include ApplicationHelper
  require 'will_paginate/array'
  require 'csv'

  before_action :get_search_defaults, only: [:index]
  before_action :load_bank_accounts, only: [:index, :export]
  before_action :load_transaction, only: [:update, :destroy]

  def index
    params[:period] = 'current_month' if params[:period].nil?
    @currencies = Currency.where(id:@bank_accounts.collect{|x| x.currency_id}.uniq).order(:name)
    # Initialize Transfer and Transaction Forms
    initialize_transfer(@bank_account)
    initialize_transaction
    # Filtering and sort Users
    @transactions = params[:period] == 'custom' ? @bank_account.transactions : @bank_account.transactions.send(params[:period])
    @transactions = @transactions.includes(:account,:sub_category).filtering(params.slice(:all_words_search,:sentence_search,:transaction_type_id,:account_id,:sub_category_id,:bank_account_id))
    @total_transactions = @transactions.count
    @transactions = @transactions.order(transactions_sort_column + " " + desc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @transactions.present?
    respond_to do |format|
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=transactions.csv"
        render 'transactions/partials/export', :layout => false
      end
      format.html do
        render 'transactions/index'
      end
    end
  end

  def create
      @transaction = Transaction.new(transaction_params)
      @transaction.sub_category_id = params[:expense_category_id].present? ? params[:expense_category_id] : params[:income_category_id]
      if params[:new_account_name].present?
        @transaction.account_id = (Account.where(name:params[:new_account_name]).first || Account.create(name:params[:new_account_name], user_id: @current_user.id)).id
      end
      if @transaction.save
        flash[:notice] = 'Transaction successfully created.'
        redirect_back(fallback_location: transactions_path(:bank_account_id => @transaction.bank_account_id))
      else
        error = params[:expense_category_id].present? ? 'expense' : 'income'
        flash[:error] = errors_to_string(@transaction.errors)
        redirect_to transactions_path(:transaction => transaction_params, :sub => @transaction.sub_category_id, errors:error)
      end
  end

  def update
    # Check Access
    @transaction = Transaction.find(params[:id])
    if @transaction.update(transaction_params)
      flash[:notice] = 'Transaction successfully created.'
      redirect_back(fallback_location: transactions_path(:bank_account_id => @transaction.bank_account_id))
    else
      # Save Failed
      error = params[:expense_category_id].present? ? 'expense' : 'income'
      flash[:error] = errors_to_string(@transaction.errors)
      redirect_to transactions_path(:transaction => transaction_params, :sub => @transaction.sub_category_id, errors:error)
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @bank_account = BankAccount.find(@transaction.bank_account_id)
    if @transaction.destroy
      flash[:notice] = 'Transaction successfully deleted.'
    else
      flash[:error] = errors_to_string(@transaction.errors)
    end
    redirect_back(fallback_location: transactions_path(:bank_account_id => @bank_account.id))
  end

  # Initializer for Creating Transaction and Transfer from Transactions Index

  # New transfer
  def initialize_transfer(bank_account)
    if params[:edit_form_id].present?
      @transfer = Transfer.find(params[:edit_form_id])
      @transfer.from_bank_account.bank_account_id = bank_account.id if bank_account.id != @transfer.from_bank_account.bank_account.id
    else
      @transfer = params[:transfer].present? ? Transfer.new(transfer_params) : Transfer.new
      @transfer.initialize_transfer unless params[:transfer].present?
      @transfer.from_bank_account.bank_account = bank_account
    end
  end

  # New Transaction
  def initialize_transaction
    @accounts_options = accounts_options
    @accounts_options_new = accounts_options(true)
    @expenses_categories = categories_options('expenses')
    @deposits_categories = categories_options('deposits')
    @transaction_new = params[:transaction].present? ? Transaction.new(transaction_params) : Transaction.new
  end

  private

  # Media Params
  def transaction_params
    params.require(:transaction).permit(:id, :bank_account_id, :account_id, :sub_category_id, :transaction_type_id, :description, :created_at, :updated_at, :amount)
  end

  def filter_params
    params.permit(
      :all_words_search,
      :sentence_search,
      :account_id,
      :transaction_type_id,
      :sub_category_id,
      :start_date,
      :end_date
    )
  end

  def load_bank_accounts
    @bank_accounts = @current_user.bank_accounts
    @bank_account = params[:bank_account_id].present? ? @bank_accounts.find(params[:bank_account_id]) : @current_user.bank_account
  end

  def load_transaction
    @transaction = Transaction.find(params[:id])
  end
end
