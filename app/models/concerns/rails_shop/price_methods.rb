# include ::RailsShop::PriceMethods
module RailsShop
  module PriceMethods
    def products
      items_relation.products
    end

    def delivery
      items_relation.deliveries.first.try(:item)
    end

    def products_total_price
      products.inject(0){|res, pr| res += (pr.amount * pr.price.to_f) }
    end

    def delivery_total_price
      delivery.try(:price) || 0
    end

    def products_discount
      return 0 unless user

      base_price = products_total_price

      if user.orders.paid.count > 0
        (base_price / 100.0)*5
      else
        (base_price / 100.0)*2
      end
    end

    def total_price
      products_total_price - products_discount + delivery_total_price
    end
  end # PriceMethods
end # RailsShop