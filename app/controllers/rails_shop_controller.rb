class RailsShopController < ApplicationController
  layout ->{ layout_for_action }

  include ::CartService::CurrentCart

  # skip_before_filter :method_to_skip, :only => [:method_name]

  before_action :authenticate_user!
  before_action :shop_admin_required

  def manage; end

  private

  def shop_admin_required
    redirect_to root_path unless current_user.admin?
  end

  def layout_for_action
    if %w[ index show ].include? action_name
      'rails_shop_frontend'
    else
      'rails_shop_backend'
    end
  end
end