Rails.application.routes.draw do
  get 'home', to: 'static_pages#home'

  devise_for :users, skip: :registration, controllers: {
    sessions: 'users/sessions', registrations: 'users/registrations'
  }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new'
    get '/users/sign_out', to: 'users/sessions#destroy'
    get '/users/registration/new', to: 'users/registrations#new'
    post '/users/registration', to: 'users/registrations#create'
  end

  namespace :admin do
    resources :users, except: %i[index show] do
      collection do
        get 'ldap_users'
      end
    end
  end

  resources :users, only: %i[index show]

  root to: 'static_pages#home'
end
