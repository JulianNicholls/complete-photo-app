Rails.application.routes.draw do
  resources :images
  devise_for :users, controllers: { registrations: 'registrations' }

  root 'welcome#index'
end
