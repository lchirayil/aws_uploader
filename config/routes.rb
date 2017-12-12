Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'uploaders#index'
  get '/failed' => 'uploaders#show'
  post '/uploaders' => 'uploaders#create'
end
