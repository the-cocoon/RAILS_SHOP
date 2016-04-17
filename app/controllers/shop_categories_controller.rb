class ShopCategoriesController < RailsShopController

  def category_klass
    ::ShopCategory
  end

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required!, except: %w[ index show ]

  include ::RailsShop::CategoryCommonController
end
