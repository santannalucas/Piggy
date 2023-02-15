class TransactionsController < ApplicationController
  include TransactionsHelper
  include ApplicationHelper
  require 'will_paginate/array'

  def index
    get_search_defaults(@current_user.options['per_page'])
    params[:period] = 'current_month' if params[:period].nil?
    # Initialize Sidebar Options
    @bank_accounts = @current_user.bank_accounts
    @bank_account = params[:bank_account_id].present? ? @bank_accounts.find(params[:bank_account_id]) : BankAccount.find(@current_user.options['default_account'].to_i)
    @currencies = Currency.where(id:@bank_accounts.collect{|x| x.currency_id}.uniq).order(:name)
    # Initialize Transfer and Transaction Forms
    initialize_transfer(@bank_account)
    initialize_transaction
    # Filtering and sort Users
    @transactions = params[:period] == 'custom' ? @bank_account.transactions : @bank_account.transactions.send(params[:period])
    @transactions = @transactions.includes(:account,:sub_category).filtering(params.slice(:all_words_search, :sentence_search,:account_id, :transaction_type_id, :sub_category_id, :start_date, :end_date))
    @total_transactions = @transactions.count
    @transactions = @transactions.order(transactions_sort_column + " " + desc_sort_direction).paginate(:page => params[:page], :per_page => params[:per_page]) if @transactions.present?
  end

  # Routed Action - Create Role
  def create
    # Check Access
      @transaction = Transaction.new(transaction_params)
      @transaction.sub_category_id = params[:expense_category_id].present? ? params[:expense_category_id] : params[:income_category_id]
      if params[:new_account_name].present?
        @transaction.account_id = (Account.where(name:params[:new_account_name]).first || Account.create(name:params[:new_account_name], user_id: @current_user.id)).id
      end
      if @transaction.save
        # Recreate Custom and CRUD Rules
        redirect_link = transactions_path(:bank_account_id => @transaction.bank_account_id)
        flash[:notice] = 'Transaction successfully created.'
      else
        # Save Failed
        error = params[:expense_category_id].present? ? 'expense' : 'income'
        redirect_link = transactions_path(:transaction => transaction_params, :sub => @transaction.sub_category_id, errors:error)
        flash[:error] = errors_to_string(@transaction.errors)
      end
      redirect_to redirect_link
  end

  def update
    # Check Access
    @transaction = Transaction.find(params[:id])
    if @transaction.update(transaction_params)
      # Recreate Custom and CRUD Rules
      redirect_link = transactions_path(:bank_account_id => @transaction.bank_account_id)
      flash[:notice] = 'Transaction successfully created.'
    else
      # Save Failed
      error = params[:expense_category_id].present? ? 'expense' : 'income'
      redirect_link = transactions_path(:transaction => transaction_params, :sub => @transaction.sub_category_id, errors:error)
      flash[:error] = errors_to_string(@transaction.errors)
    end
    redirect_to redirect_link
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @bank_account = BankAccount.find(@transaction.bank_account_id)
    if @transaction.destroy
      redirect_link =
      flash[:notice] = 'Transaction successfully deleted.'
    else
      flash[:error] = errors_to_string(@transaction.errors)
    end
    redirect_to transactions_path(:bank_account_id => @bank_account.id)
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

end
