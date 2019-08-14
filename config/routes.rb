Rails.application.routes.draw do
  get 'hello_world', to: 'hello_world#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root       'photos#index'
  get        '/myphotos', to: 'photos#myphotos', as: 'myphotos'
  resources  :photos, only: [:index, :show, :create, :destroy]
  resource   :map, only:    [:show]
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup'}
end
