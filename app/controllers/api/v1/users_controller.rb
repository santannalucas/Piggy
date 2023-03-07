class Api::V1::UsersController < Api::V1::BaseController

  def index
    if can?(:user,:search)
      @users = User.all
      render json: @users
    else
      unauthorized
    end
  end

  def show
    if can?(:user,:read)
      @user = User.find(params[:id])
      render json: @user
    else
      unauthorized
    end
  end

  def create
    if can?(:user,:create)
      if @user.create(user_params)
        render json: @user
      else
        render json: @user.errors.full_messages
      end
    else
      unauthorized
    end
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

  def navbar
    u = @current_user
    render json: {name: u.name, navbar:u.navbar_json.to_s, initials: u.initials, email: u.email}
  end

  def unauthorized
    render json: {'error':'Unauthorized'}, status: :unauthorized
  end
  private # Controller Private Methods

  # User Secure Params
  def user_params
    params.require(:user).permit(:name, :email, :password, :role_id, :options)
  end

end