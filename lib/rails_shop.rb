_root_ = File.expand_path('../../', __FILE__)

require "rails_shop/version"

%w[
  slim
  sass
  config
  pagination
  simple_sort
  to_slug_param
  the_string_addon

  log_js
  ptz_tabs
  role_slim_js
  notifications
  awesome_nested_set

  protozaur
  protozaur_theme
].each do |lib|
  require lib
end

module RailsShop
  class Engine < Rails::Engine
    # config.autoload_paths += %W()
    config.autoload_paths << "#{ config.root }/app/mailers/concerns/"
    # config.assets.paths << config.root.join("app", "assets", "components")

    initializer "RailsShop: static assets" do |app|
      app.middleware.use(::ActionDispatch::Static, "#{ config.root }/public")
    end

    initializer :add_rails_shop_view_paths do

      ActiveSupport.on_load(:active_record) do
        _root_ = ::RailsShop::Engine.config.root
        ::Rails.application.config.paths['db/migrate'] << "#{ _root_ }/db/migrate"
      end

      ActiveSupport.on_load(:action_controller) do
        _root_  = ::RailsShop::Engine.config.root
        views_1 = "app/views/rails_shop"
        prepend_view_path("#{ _root_ }/#{ views_1 }" ) if respond_to?(:prepend_view_path)
      end
    end
  end
end

# Routing cocerns loading
require "#{ _root_ }/config/routes"
