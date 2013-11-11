Iox::Engine.routes.draw do

  resources :cloud_containers do
    resources :repos
    resources :privileges, controller: :cloud_privileges
    collection do
      get :crypted
    end
  end

  resources :cc, controller: 'iox/cloud_containers'

end
