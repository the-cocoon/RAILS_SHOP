# include ::RailsShop::PriceMethods
module RailsShop
  module PriceMethods

    def products_total_price
      products.inject(0){|res, cart_item| res += (cart_item.amount * cart_item.item.discounted_price.to_f) }
    end

    def delivery_total_price
      delivery.try(:price) || 0
    end

    def total_price
      products_total_price - products_discount + delivery_total_price
    end

    def products
      items_relation.products
    end

    def delivery
      items_relation.deliveries.first.try(:item)
    end

    def products_discount
      return 0

      return 0 unless user

      base_price = products_total_price

      if user.orders.paid.count > 0
        (base_price / 100.0)*2
      else
        (base_price / 100.0)*1
      end
    end
  end # PriceMethods
end # RailsShop