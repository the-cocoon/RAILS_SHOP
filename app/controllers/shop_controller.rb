class ShopController < RailsShopController
  layout 'layouts/table-holy-grail'

  before_action :authenticate_user!
  before_action :shop_admin_required

  def manage; end
end
