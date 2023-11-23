Rails.application.routes.draw do
  get 'commits/show'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/repositories/:owner/:repository/commit/:commit_sha', to: 'commits#show'

  # Defines the root path route ("/")
  # root "articles#index"
end
