Rails.application.routes.draw do
  get '/' => 'uploaders#index'
  get '/:year' => 'uploaders#year'
  get '/:year/:month' => 'uploaders#month'
  post '/uploaders' => 'uploaders#create'
end
