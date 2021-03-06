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

      get   'yandex_market/index'      => 'yandex_market#index',  as: :yandex_market
      patch 'yandex_market/switch/:id' => 'yandex_market#switch', as: :yandex_market_switch

      get   'yandex_market/export' => 'yandex_market#export', as: :yandex_market_export
      get   'yandex_market/export_this/:id' => 'yandex_market#export_this', as: :yandex_market_export_this

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
          post  :clone
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

      # Yandex Kassa routes
      match 'payments/yk/check-url' => 'payments#yk_check',   via: %w[ get post ]
      match 'payments/yk/aviso-url' => 'payments#yk_aviso',   via: %w[ get post ]
      match 'payments/yk/success'   => 'payments#yk_success', via: %w[ get post ]
      match 'payments/yk/failure'   => 'payments#yk_failure', via: %w[ get post ]

      # Alfa Bank routes
      post 'alfa_payments' => 'payments#alfa_before'
      get  'alfa_callback' => 'payments#alfa_callback'
      get  'alfa_success'  => 'payments#alfa_success'
      get  'alfa_failure'  => 'payments#alfa_failure'

      ##########################
      # ~ SHOP
      ##########################
    end
  end
end
