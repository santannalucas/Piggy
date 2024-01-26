class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  include SessionsHelper
  include ApplicationHelper
  include JsonWebToken
  before_action :logged_in_user

  # Return Params to Enable Search Filtering and Pagination
  def get_search_defaults
    params[:page] = 1 if params[:page].nil? || params[:page].empty?
    params[:per_page] = @current_user&.options['per_page'] if params[:per_page].nil?
    params[:full_sentence] ? params[:sentence_search] = params[:search] : params[:all_words_search] = params[:search]
  end

  def failed_access(message,action,details = nil)
    access_log("<font color='red'><b>!! #{message} !!</font>", action, details)
    flash[:error] = "You don't have access rights to #{message}."
    redirect_back(fallback_location: root_path)
  end

  def filter_and_sort(klass, filters, sort)

  end

  private

  # Media Params
  def transfer_params
    params.require(:transfer).permit(
      :id, :from_id, :to_id, :rate, :created_at, :description,
      # From Account
      from_bank_account_attributes: [ :id, :bank_account_id, :sub_category_id, :description, :amount, :transfer, :created_at],
      # To Account
      to_bank_account_attributes: [:id, :bank_account_id, :sub_category_id, :description, :amount, :transfer, :created_at]
    )
  end

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to root_path
    end
  end
end
