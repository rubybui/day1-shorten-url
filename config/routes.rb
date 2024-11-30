Rails.application.routes.draw do
  root 'urls#new'
  resources :urls, only: [:new, :create]
  get '/:short_url', to: 'urls#redirect', as: :redirect
end
