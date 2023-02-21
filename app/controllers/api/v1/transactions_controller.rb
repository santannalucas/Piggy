class Api::V1::TransactionsController < Api::V1::BaseController
  include TransactionsHelper
  include ApplicationHelper
  # skip_before_action :logged_in_user, only: [:show, :index]
  # https://www.youtube.com/watch?v=_rdNv5ijzrk&list=PLgYiyoyNPrv_yNp5Pzsx0A3gQ8-tfg66j&index=4
  def index
    params[:period] = 'current_month' if params[:period].nil?
    # Initialize Sidebar Options
    @bank_account = params[:bank_account_id].present? ? @bank_accounts.find(params[:bank_account_id]) : BankAccount.find(@current_user.options['default_account'].to_i)
    # Filtering and sort Users
    @transactions = params[:period] == 'custom' ? @bank_account.transactions : @bank_account.transactions.send(params[:period])
    @transactions = @transactions.includes(:account,:sub_category).filtering(params.slice(:account_id, :transaction_type_id, :sub_category_id, :start_date, :end_date))
    render json: @transactions.order(transactions_sort_column + " " + desc_sort_direction)
  end

end