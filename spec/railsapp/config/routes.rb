Rails.application.routes.draw do
  resources :companies

  root 'home#index'
end
