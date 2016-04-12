# include ::RailsShop::ProductPriceMethods
module RailsShop
  module ProductPriceMethods
    def total_price
      active_price.to_f - (active_price.to_f/100)*discount_percent
    end

    def active_price_with_discount
      active_price.to_f - (active_price.to_f/100)*discount_percent
    end

    # Product.recalc_actual_price!
    def self.recalc_actual_price!
      ::Product.where.not(eur_price: nil).each{|pr| pr.recalc_actual_price! }
      ::Product.where.not(usd_price: nil).each{|pr| pr.recalc_actual_price! }
    end

    def recalc_actual_price!
      curr_rate = ::CurrencyRate.max2min(:created_at).first
      return unless curr_rate

      if eur_price.to_f > 0
        update_attribute(:active_price, eur_price.to_f * curr_rate.rur_eur.to_f)

      elsif usd_price.to_f > 0
        update_attribute(:active_price, usd_price.to_f * curr_rate.rur_usd.to_f)
      else
        update_attribute(:active_price, rur_price.to_f)
      end
    end


  end
end
