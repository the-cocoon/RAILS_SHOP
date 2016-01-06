class Cart < ActiveRecord::Base
  include ::SimpleSort::Base
  include ::Pagination::Base

  include ::RailsShop::PriceMethods

  def to_param; self.uid; end

  # expire time in hours
  EXPIRE_AFTER = 3 * 24

  belongs_to :user
  before_validation :build_uid, on: :create

  has_many :cart_items
  def items_relation; cart_items; end

  scope :empty,  -> { where     cart_items_counter: 0 }
  scope :filled, -> { where.not cart_items_counter: 0 }

  scope :active,  -> { where 'carts.created_at > ?', (Time.zone.now - ::Cart::EXPIRE_AFTER.hours) }
  scope :expired, -> { where 'carts.created_at < ?', (Time.zone.now - ::Cart::EXPIRE_AFTER.hours) }

  def active?
    created_at > (Time.zone.now - ::Cart::EXPIRE_AFTER.hours)
  end

  class << self
    def recalc_items_counter!
      all.each do |cart|
        cart.update_attribute(:cart_items_counter, cart.cart_items.count)
      end
    end

    def destroy_expired!
      empty.expired.destroy_all
    end
  end

  private

  def build_uid
    self.uid = Digest::MD5.hexdigest("#{ Time.now }-#{ rand }")[0...7].downcase
  end
end
