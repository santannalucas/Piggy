Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'sessions#new'
  get 'login'    => 'sessions#new'

  get 'login'    => 'sessions#new'
  post 'login'   => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  get 'dashboard' => 'dashboard#dashboard'

  resources :transactions

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
    put 'update_item'
    post 'create_item'
    delete 'delete_item'
    get 'pay'
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

end
