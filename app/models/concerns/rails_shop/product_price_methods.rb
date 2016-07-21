# include ::RailsShop::ProductPriceMethods
module RailsShop
  module ProductPriceMethods
    extend ActiveSupport::Concern
    include ::ProductPriceHelper

    class_methods do
      # Product.recalc_actual_price!
      def recalc_actual_price!
        ::Product.where.not(eur_price: nil).each{|pr| pr.recalc_actual_price! }
        ::Product.where.not(usd_price: nil).each{|pr| pr.recalc_actual_price! }
      end
    end

    def active_price_with_discount
      product_discounted_price(self)
    end

    def total_price
      product_price(self)
    end

    def recalc_actual_price!
      if eur_price.to_f.zero? && usd_price.to_f.zero?
        return update_attribute(:active_price, rur_price.to_f)
      end

      curr_rate = ::CurrencyRate.max2min(:created_at).first
      return unless curr_rate

      if eur_price.to_f > 0
        update_attribute(:active_price, eur_price.to_f * curr_rate.rur_eur.to_f)
      elsif usd_price.to_f > 0
        update_attribute(:active_price, usd_price.to_f * curr_rate.rur_usd.to_f)
      end
    end
  end
end
