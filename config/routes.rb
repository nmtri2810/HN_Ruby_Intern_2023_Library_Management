Rails.application.routes.draw do
  namespace :admin do
    scope "(:locale)", locale: /en|vi/ do
      root "home#index"
      get "/login", to: "sessions#new"
      post "/login", to: "sessions#create"
      delete "/logout", to: "sessions#destroy"

      resources :authors, :genres, :publishers
      resources :books do
        member do
          get :amend, to: "books#amend_edit"
          get :authors, :genres
          post :amend
        end
      end
      resources :users, only: %i(index show) do
        member do
          post :active, :inactive
        end
      end
      resources :borrows, only: %i(index show), constraints: {id: /\d+/} do
        member do
          post :approve, :reject, :return, :remind
        end
        collection do
          get ":group", to: "borrows#index", as: "",
                        constraints: {group: /pending|history|approved/},
                        defaults: {group: :approved}
        end
      end

    end
  end

  scope "(:locale)", locale: /en|vi/ do
    root "home#index"
    get "/signup", to: "accounts#new"
    post "/signup", to: "accounts#create"
    resources :accounts, only: %i(show edit update)

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :books, only: %i(index show), path: "library"
    resources :authors, only: %i(show)

    resource :carts, only: %i(show destroy)
    resources :borrow_items, only: %i(create destroy)
    resources :borrow_infos, only: %i(index show new create)
    post "/status_action", to: "borrow_infos#handle_status_action"
    patch "/status_action", to: "borrow_infos#handle_status_action"
  end
end
