class Order < ActiveRecord::Base
  # You have to implement your own `ProductPriceHelper`
  # in your App View
  include ::ProductPriceHelper

  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::Notifications::LocalizedErrors

  include ::RailsShop::OrderStates
  include ::RailsShop::OrderDeliveryValidations

  # expire time in hours
  EXPIRE_AFTER = 3 * 24

  EMAIL_REGEXP = /@/

  PS_NAME_ID = { card: :AC, yadengi: :PC, alfa_bank: :AB, promsvyaz_bank: :PB, web_money: :WM, euroset: :GP, svyaznoy: :GP, sberbank: :SB, qiwi: :QW }
  PS_ID_NAME = PS_NAME_ID.map{|k,v| [v,k] }.to_h

  def to_param; self.uid; end

  belongs_to :user
  has_many :order_items
  before_validation :build_uid, on: :create

  def items_relation; order_items; end

  def products
    items_relation.products
  end

  def delivery
    items_relation.deliveries.first.try(:item)
  end

  def ready_for_sale?
    is_ready = true
    product_positions = products

    product_positions.each do |product_position|
      product = product_position.item
      is_ready = false if product_position.amount > product.amount
    end

    is_ready
  end

  # COMPLEX PROCESSORS

  def recalc_price!
    recalc_products_price!
    recalc_delivery_price!
    recalc_discount!
    recalc_total_price!
  end

  def process_cart_after_create!(cart)
    # Attach products form Cart to Order
    cart.cart_items.products.each do |cart_item|
      order_items.create(
        item:   cart_item.item,
        amount: cart_item.amount,
        price:  cart_item.price
      )
    end

    # Fix products count
    update_attribute(:order_items_counter, products.count)

    # Attach delivery type form Cart to Order
    order_items.create(item: cart.delivery)
    recalc_price!

    send_created_notification!
  end

  def process_completion_step!
    # Some positions might need moderation
    # or it can be ready for payment right now
    define_ready_to_payment!
    send_state_changes_notification!
  end

  def process_payment_complete!
    products_reserve! if !paid?
    paid!
    send_state_changes_notification!
  end

  # PRICE CALCULATIONS

  def recalc_products_price!
    ps_price = products.inject(0) do |res, order_item|
      res + (order_item.amount * product_discounted_price(order_item.item))
    end

    update_attribute(:products_price, ps_price)
  end

  def recalc_delivery_price!
    d_price = delivery.price
    update_attribute(:delivery_price, d_price)
  end

  def recalc_discount!
    dis = user ? discount_value : 0
    update_attribute(:discount, dis)
  end

  def recalc_total_price!
    t_price = products_price.to_f + delivery_price.to_f - discount.to_f
    update_attribute(:total_price, t_price)
  end

  # ~~~ DISCOUNT ~~~

  def discount_percent
    return 0

    return 0 unless user
    return 5 if user.orders.paid.count > 0
    2
  end

  def discount_value
    (products_price / 100.0) * discount_percent
  end

  # PRODUCTS IN STOCK PROCESSING

  def products_reserve!
    product_positions = products

    product_positions.each do |product_position|
      product = product_position.item
      product.decrement! :amount, product_position.amount
    end

    # Calc diff
    # SEND email with diff
  end

  def products_refund!
    product_positions = products

    product_positions.each do |product_position|
      product = product_position.item
      product.increment! :amount, product_position.amount
    end

    # Calc diff
    # SEND email with diff
  end

  # STATE HELPERS
  def current_state
    return :expired if expired_order?
    state
  end

  def expired_order?
    expired_moment = created_at + ::Order::EXPIRE_AFTER.hours
    expired_moment < Time.zone.now
  end
  # ~ STATE HELPERS

  # SERVICE METHODS

  def self.recalc_items_counters!
    Order.all.each do |order|
      order.update_attribute(:order_items_counter, order.products.count)
    end
  end

  private

  def build_uid
    self.uid = Digest::MD5.hexdigest("#{ Time.now }-#{ rand }")[0...7].downcase
  end
end
