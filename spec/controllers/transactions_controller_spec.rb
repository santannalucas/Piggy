require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'assigns all transactions to @transactions' do
      transactions = FactoryBot.create_list(:transaction, 3) # Assuming you're using FactoryBot to create test data
      get :index
      expect(assigns(:transactions)).to eq(transactions)
    end
  end
end
