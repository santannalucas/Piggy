class DashboardController < ApplicationController

  def dashboard
    params[:period] = 'current_month' if params[:period].nil?
    params[:year] = Time.now.year if params[:year].nil?
    params[:month] = Time.now.month if params[:month].nil?

    @bank_accounts = @current_user.bank_accounts.where(dashboard:true).order(:currency_id,:name)
    @currencies = Currency.where(id:@bank_accounts.collect{|x| x.currency_id}.uniq).order(:name)
    @bank_account = params[:bank_account_id].present? ? BankAccount.find(params[:bank_account_id]) : @current_user.bank_account

    # Bills to Pay / Receive
    @bills = @current_user.scheduler_items.joins(:scheduler).year_month(params[:year],params[:month]).order(:created_at)

    # Pie Chart
    @pie_chart = @current_user.total_on_period(params[:year].to_i, params[:month].to_i,'expenses',@bank_account.id.to_i).unshift(%w[Category Total])

    # Current Month
    @current =  @current_user.transactions.bank_account_id(@bank_account.id).no_transfers.year_month(params[:year],params[:month])
    @out_current = @current.expenses.total_in_currency(@current_user)
    @in_current = @current.deposits.total_in_currency(@current_user)
    @out_unpaid = @bills.unpaid.where('schedulers.transaction_type_id = 3').sum(:amount)
    @in_unpaid =  @bills.unpaid.where('schedulers.transaction_type_id = 2').sum(:amount)

    # Totals
    @out_total = @out_current + @out_unpaid
    @in_total = @in_current + @in_unpaid
    @paid_total = @in_total - @out_total
    @total = @in_current - @out_current

    # Year
    @monthly_total = @current_user.transactions.bank_account_id(@bank_account.id).no_transfers.monthly_total(@current_user,params[:year], 1)
    @calendar = @current_user.current_month_payments(params[:year].to_i,params[:month].to_i)

  end

end
