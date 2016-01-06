class RailsShopController < ApplicationController
  include ::CartService::CurrentCart

  layout 'layouts/table-holy-grail'

  private

  def shop_admin_required
    redirect_to root_path unless current_user.admin?
  end
end
