class RailsShopController < ApplicationController
  layout ->{ layout_for_action }

  include ::CartService::CurrentCart

  # USE THIS METHODS WHEN YOU NEED TO SKIP AUTH FILTERS
  #
  # skip_before_filter :authenticate_user!,   only: [:method_name]
  # skip_before_filter :shop_admin_required!, only: [:method_name]

  before_action :authenticate_user!
  before_action :shop_admin_required!

  def manage; end

  private

  def shop_admin_required!
    redirect_to root_path unless current_user.try(:admin?)
  end

  def layout_for_action
    if %w[ index show ].include? action_name
      'rails_shop_frontend'
    else
      'rails_shop_backend'
    end
  end
end