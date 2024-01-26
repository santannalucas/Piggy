class Api::V1::TransactionTypesController < Api::V1::BaseController

  def index
    @transaction_types = TransactionType.where.not(name:'system')
    render json:  @transaction_types
  end

end