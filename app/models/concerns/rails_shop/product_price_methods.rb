# include ::RailsShop::ProductPriceMethods
module RailsShop
  module ProductPriceMethods
    extend ActiveSupport::Concern
    # You have to implement your own `ProductPriceHelper`
    # in your App View
    include ::ProductPriceHelper

    included do
      before_validation :recalc_price
    end

    # Product.recalc_prices!
    class_methods do
      def recalc_prices!
        ::Product.all.each{|pr| pr.recalc_price! }
      end
    end

    def has_discount?
      price != discounted_price
    end

    def recalc_price
      self.price = product_price(self)
      self.discounted_price = product_discounted_price(self)
    end

    def recalc_price!
      update_attributes(
        price: product_price(self),
        discounted_price: product_discounted_price(self)
      )
    end
  end
end
