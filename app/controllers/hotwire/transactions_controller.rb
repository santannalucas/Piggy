class Hotwire::TransactionsController < ApplicationController
  def index
    @transactions = @current_user&.transactions&.last(30)
  end
end