class Api::V1::Config::AccountsController < Api::V1::BaseController

  def index
    @accounts = @current_user.accounts
    render json:  @accounts
  end

  def show
    @account = Account.find(params[:id])
    render json: {account:@account}
  end
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created
    else
      render json: { errors: @account.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def account_params
    params.require(:account).permit(:name, :description, :transaction_type_id)
  end
end