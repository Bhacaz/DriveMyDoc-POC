# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  resources :sessions, only: %i[create destroy]

  get 'drive', to: 'drive#index'
  get 'drive/:id', to: 'drive#show'

  resource :home, only: [:show]
  root to: 'sessions#show'
end
