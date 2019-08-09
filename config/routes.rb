Rails.application.routes.draw do
  get 'hello_world', to: 'hello_world#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'photos#index'
  resources :photos, only: [:index, :show, :create]
  resource :map, only: [:show]
end
