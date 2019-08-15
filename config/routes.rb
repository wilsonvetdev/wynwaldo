Rails.application.routes.draw do
  default_url_options :host => "wynwaldo.herokuapp.com"
  get 'hello_world', to: 'hello_world#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root       'photos#index'

  namespace :my do
    resources :photos, only: [:index]
  end

  resources  :photos, only: [:index, :show, :create, :destroy]
  resource   :map, only:    [:show]
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup'}
end
