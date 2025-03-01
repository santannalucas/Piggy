Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'sessions#new'
  get 'login'    => 'sessions#new'
  post 'login'   => 'sessions#create'
  post 'login_api' => 'sessions#api_login'
  delete 'logout' => 'sessions#destroy'

  get 'dashboard' => 'dashboard#dashboard'

  resources :transactions do
    collection do
      get 'export'
    end
  end

  namespace :hotwire do
    resources :transactions
  end

  resources :transfers

  # System Admin Module
  scope module: 'config' do
    resources :categories
    resources :sub_categories
    resources :accounts
    resources :currencies
    resources :bank_accounts
  end

  resources :schedulers do
    resources :scheduler_items, only: [:create, :update, :destroy], controller: 'schedulers/scheduler_items'
    get 'pay'
    post 'complete_pay_all'
  end

  resources :reports

  # System Admin Module
  scope module: 'admin' do
    # Roles
    resources :roles, :only => [:show, :create, :update]
    # Rules
    resources :rules, :only => [:index, :update] do
      collection do
        put 'update_role_custom'
        post 'create_role_custom'
      end
    end
    put 'custom_rule', action: :update_custom, controller: 'rules'
    get 'workspace', action: :workspace, controller: 'rules'
    get 'role', action: :role, controller: 'rules'
    # Users
    resources :users
  end

  scope module: 'tools' do
    resources :import_files
  end
end
