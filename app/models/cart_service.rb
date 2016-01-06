module CartService
  #################################
  # USER methods
  #################################

  # Helpers for Shop Controllers and Views
  #
  # include ::CartService::CurrentCart
  module CurrentCart
    extend ActiveSupport::Concern

    included do
      helper_method :current_cart
    end

    def current_cart
      @current_cart ||= current_user ? \
        ::CartService.define_current_user_cart(current_user, cookies) : \
        ::CartService.define_guest_cart(cookies)
    end
  end

  # Service methods for Shop Controllers
  #
  class << self
    def store_current_cart(cart, cookies)
      return nil unless cart

      cookies[:cart_uid] = {
        value:   cart.uid,
        expires: ::Cart::EXPIRE_AFTER.hours.from_now
      }

      cart
    end

    def reset_current_cart(cookies)
      cookies.delete(:cart_uid)
    end

    def define_new_cart_with(current_user, cookies)
      cart = current_user ? current_user.carts.create : ::Cart.create
      store_current_cart(cart, cookies)
    end

    def define_cart(uid, current_user, cookies)
      ::Cart.where(uid: uid).first || define_new_cart_with(current_user, cookies)
    end

    def active_cart(current_user, cookies)
      cart_uid = cookies[:cart_uid]
      current_user.carts.active.where(uid: cart_uid).first if cart_uid
    end

    def delete_cart(cart, cookies)
      cart.cart_items.deliveries.destroy_all
      cookies.delete(:cart_uid)
    end

    def delete_cart_if_need(cart, cookies)
      delete_cart(cart, cookies) if cart.cart_items.products.empty?
    end

    def add_default_delivery_if_need(cart)
      if cart.cart_items.deliveries.empty? && dt = ::DeliveryType.default_option.first
        cart.cart_items.create(item: dt)
      end
    end

    def append_cart_if_need(current_user, cookies)
      return nil unless cart_uid = cookies[:cart_uid]
      return nil unless cart = ::Cart.where(uid: cart_uid).first

      if cart && cart.user.blank?
        cart.update(user_id: current_user.id, created_at: Time.current)
        store_current_cart(cart, cookies)
      end
    end

    def define_current_user_cart(current_user, cookies)
      append_cart_if_need(current_user, cookies)
      active_cart(current_user, cookies)
    end

    def define_guest_cart(cookies)
      cart_uid = cookies[:cart_uid]
      Cart.active.where(uid: cart_uid, user_id: nil).first if cart_uid
    end
  end # class << self
end