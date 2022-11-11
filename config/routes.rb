Rails.application.routes.draw do
  devise_for :accounts
  get "/u/:username", to: 'public#profile', as: :profile
  
  resources :communities do
    resources :posts
  end

  resources :subscriptions, except: :destroy
  delete '/subscriptions/:community_id', to: 'subscriptions#destroy'

  resources :comments, only: [:create]


  root to: 'public#index'
  
end
