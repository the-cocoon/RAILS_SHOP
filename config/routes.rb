module RailsShop
  # ::RailsShop::Routes.mixin(self)
  class Routes
    def self.mixin mapper
      mapper.extend ::RailsShop::DefaultRoutes
      mapper.send :rails_shop_routes
    end
  end

  module DefaultRoutes
    def rails_shop_routes
      get 'shop_search' => "shop_search#shop_search"

      get 'products_search_a/:term' => "shop_search#ts_products_search"
      get 'products_search_b/:term' => "shop_search#psql_products_search"
      get 'products_search_c/:term' => "shop_search#psql_products_search2"

      get '/shop'       => 'products#index', as: :shop
      get 'shop/manage' => 'shop#manage',    as: :shop_manage

      get   'yandex_market/index'  => 'yandex_market#index',  as: :yandex_market
      patch 'yandex_market/switch' => 'yandex_market#switch', as: :yandex_market_switch
      patch 'yandex_market/update' => 'yandex_market#update', as: :yandex_market_update

      resources :shop_params_cards

      resources :shop_categories do
        member do
          get :ordering
        end

        collection do
          get  :manage
          post :rebuild
        end
      end

      resources :shop_brands do
        collection do
          get  :manage
          post :rebuild
        end
      end

      resources :shop_colors do
        collection do
          get  :manage
          post :rebuild
        end
      end

      resources :shop_unit_ports do
        collection do
          get  :manage
          post :rebuild
        end
      end

      get "shop_ordering/:category_type/:category_id",
        action: :ordering,
        controller: :shop_category_rels,
        as: :shop_ordering

      resources :shop_category_rels do
        collection do
          get  :manage
          post :rebuild
        end
      end

      resources :products do
        member do
          patch :realtion_category
        end

        collection do
          get :manage
        end
      end

      # ADD/REMOVE PRODUCTS
      post   "add_to_cart/:product_id"      => "carts#add_product",    as: :add_to_cart
      delete "remove_from_cart/:product_id" => "carts#remove_product", as: :remove_from_cart

      resources :carts do
        member do
          delete :reset
          patch :set_delivery_type

          patch  :amount_decrement
          patch  :amount_increment
        end

        collection do
          get :manage
        end
      end

      resources :orders do
        member do
          get :payment_system
          get :login_before
          get :attach_current_user_to

          patch :recalc_price
          patch :completion
          get   :payment
        end

        collection do
          get :my
          get :search
          get :manage

          post :one_click
        end
      end

      resources :currency_rates do
        collection do
          get :cbr_get_rate
          get :manage
        end
      end

      resources :delivery_types do
        collection do
          get :manage
        end
      end

      # Yandex Kassa test routes
      #
      # match 'payments/test/yk/check-url' => 'payments#yk_check_test',   via: %w[ get post ]
      # match 'payments/test/yk/aviso-url' => 'payments#yk_aviso_test',   via: %w[ get post ]
      # match 'payments/test/yk/success'   => 'payments#yk_success_test', via: %w[ get post ]
      # match 'payments/test/yk/failure'   => 'payments#yk_failure_test', via: %w[ get post ]

      # Yandex Kassa routes
      match 'payments/yk/check-url' => 'payments#yk_check',   via: %w[ get post ]
      match 'payments/yk/aviso-url' => 'payments#yk_aviso',   via: %w[ get post ]
      match 'payments/yk/success'   => 'payments#yk_success', via: %w[ get post ]
      match 'payments/yk/failure'   => 'payments#yk_failure', via: %w[ get post ]

      ##########################
      # ~ SHOP
      ##########################
    end
  end
end
