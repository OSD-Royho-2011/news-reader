require 'sidekiq/pro/web'
require 'sidekiq-ent/web'
Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root :to => "news#index"
  resources :news
  mount Sidekiq::Web, at: "/sidekiq"
end
