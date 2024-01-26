# spec/controllers/sessions_controller_spec.rb
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  include SessionsHelper

  let(:user) { FactoryBot.create(:user) }

  describe "GET #new" do
    it "renders the new template when not logged in" do
      get :new
      expect(response).to render_template("new")
    end

    it "redirects to dashboard when logged in" do
      log_in user
      get :new
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "POST #create" do
    it "logs in the user and redirects to dashboard on successful login" do
      post :create, params: { session: { email: user.email, password: user.password } }
      expect(response).to redirect_to(dashboard_path)
      expect(session[:user_id]).to eq(user.id)
    end

    it "renders the new template with an error message on unsuccessful login" do
      post :create, params: { session: { email: user.email, password: 'incorrect_password' } }
      expect(response).to render_template("new")
      expect(flash[:danger]).to be_present
    end
  end

  describe "POST #api_login" do
    it "returns a token on successful API login" do
      post :api_login, params: { session: { email: user.email, password: user.password } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["token"]).to be_present
    end

    it "returns unauthorized status on unsuccessful API login" do
      post :api_login, params: { session: { email: user.email, password: 'incorrect_password' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE #destroy" do
    it "logs out the user and redirects to the root URL" do
      log_in user
      delete :destroy
      expect(response).to redirect_to(root_url)
      expect(session[:user_id]).to be_nil
    end
  end
end
