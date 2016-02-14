class ShopUnitPortsController < RailsShopController
  layout 'rails_shop_layout'

  def category_klass
    ::ShopUnitPort
  end

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  include ::RailsShop::CategoryCommonController
end
