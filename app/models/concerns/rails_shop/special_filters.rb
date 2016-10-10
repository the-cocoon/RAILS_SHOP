# include ::RailsShop::SpecialFilters
module RailsShop
  module SpecialFilters
    extend ActiveSupport::Concern

    included do
      scope :special_filter, ->(params){
         special_in_stock(params)
        .special_preorder(params)
        .special_cheap(params)
        .expensive(params)
      }

      scope :special_in_stock, ->(params){
        reorder('item_amount DESC') if params[:sfilter] == 'in_stock'
      }

      scope :special_preorder, ->(params) {
        reorder('item_amount ASC') if params[:sfilter] == 'preorder'
      }

      scope :special_cheap, ->(params){
        reorder('item_price ASC') if params[:sfilter] == 'cheap'
      }

      scope :expensive, ->(params){
        reorder('item_price DESC') if params[:sfilter] == 'expensive'
      }
    end
  end
end
