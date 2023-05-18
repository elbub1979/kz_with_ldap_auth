Rails.application.routes.draw do
  get 'home', to: 'static_pages#home'

  devise_for :users, controllers: {
    sessions: 'users/sessions', users: 'users', registrations: 'users/registrations'
  }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get '/users/sign_out', to: 'users/sessions#destroy'

    resources :users
    # get '/users/new', to: 'users#new'
    # get '/users/:id', to: 'users#show'
    # post '/users/:id', to: 'users#create'
  end

  root to: 'static_pages#home'
end
