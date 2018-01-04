Rails.application.routes.draw do
  root 'uploaders#index'
  get '/search' => 'uploaders#search'
  get '/:year' => 'uploaders#year'
  get '/:year/:month' => 'uploaders#month'
  post '/uploaders' => 'uploaders#create'
end
