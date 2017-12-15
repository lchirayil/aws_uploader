Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations, :passwords, :confirmations, :mailer]
  root 'uploaders#index'
  get '/:year' => 'uploaders#year'
  get '/:year/:month' => 'uploaders#month'
  post '/uploaders' => 'uploaders#create'
end
