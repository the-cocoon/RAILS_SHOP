module RailsShopLogger
  class << self
    DEV_LOGGING = false

    def delay_time
      5.seconds
    end

    def product_added_to_cart(cart_id, product_id)
      log_with do
        RailsShopLoggerMailer.delay_for(delay_time).product_added_to_cart(cart_id, product_id)
      end
    end

    def product_removed_from_cart(cart_id, product_id)
      log_with do
        RailsShopLoggerMailer.delay_for(delay_time).product_removed_from_cart(cart_id, product_id)
      end
    end

    def selected_payment_system(order_id, payment_system_name)
      log_with do
        RailsShopLoggerMailer.delay_for(delay_time).selected_payment_system(order_id, payment_system_name)
      end
    end

    private

    def logging?
      return DEV_LOGGING if Rails.env.development?
      true
    end

    def log_with
      if logging?
        begin;
          yield
        rescue; end;
      else
        p '*'*50
        p 'Log action completed'
        p'*'*50
      end
    end
  end
end