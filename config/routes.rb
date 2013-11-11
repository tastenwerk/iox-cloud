Iox::Engine.routes.draw do

  resources :cloud_containers do
    resources :repos
  end

  resources :cc, controller: 'iox/cloud_containers'

end
