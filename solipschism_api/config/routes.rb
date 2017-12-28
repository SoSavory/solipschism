Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'users/create'

  get 'aliases/index'

  get 'articles/index'
  get 'articles/show/:id' => "articles#show"
  get 'articles/show_matched_day/:date' => "articles#show_matched_day"
  post 'articles/create'

  get 'coordinates/index'
  post 'coordinates/update'
  # get 'coordinates/require_computation_set'
  # post 'coordinates/upload_matched_aliases'


  scope :format => true, :constraints => { :format => 'json' } do
    post "/login"    => "sessions#create"
    delete "/logout" => "sessions#destroy"
  end
end
