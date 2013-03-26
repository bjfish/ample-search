require 'resque/server'

Indexer::Application.routes.draw do
  get "policy/tos"
  match "help" => "policy#help"
  get "policy/privacy"

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_scope :admin_users do
    mount Resque::Server.new, :at => "/resque" 
  end

  authenticated :user do
    root :to => 'home#search'
  end
  root :to => "home#index"

  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",:registrations => "registrations"  }

  resources :accounts do
    resources :account_members
  end
  resources :integrations do
    get 'job_status', :on => :member
    post 'index_now', :on => :member
    resources :authorizations
  end

  #match 'integrations/bitbucket' => 'integrations#bitbucket'
  #match 'integrations/trello' => 'integrations#trello'

  # match 'integrations' => 'integrations#index'#
  # match 'integrations/:id/add' => 'integrations#add'#
  # match 'integrations/:id/retrieve' => 'integrations#retrieve'#
  # match 'integrations/:id/job-status' => 'integrations#job_status'#

  #mount Resque::Server.new, :at => "/resque"   #TODO Make this secure for admins
  get "home/search"

# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)

# Sample resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Sample resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     collection do
#       get 'sold'
#     end
#   end

# Sample resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Sample resource route with more complex sub-resources
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', :on => :collection
#     end
#   end

# Sample resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end

# You can have the root of your site routed with "root"
# just remember to delete public/index.html.
# root :to => 'welcome#index'

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id))(.:format)'
end
