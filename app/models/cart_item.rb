class CartItem < ActiveRecord::Base
  include ::SimpleSort::Base

  belongs_to :cart
  belongs_to :item, polymorphic: true
  validates  :item_id, uniqueness: { scope: [ :cart_id, :item_type ]}

  scope :products,   ->{ where(item_type: :Product) }
  scope :deliveries, ->{ where(item_type: :DeliveryType) }

  def total_price
    amount * item.discounted_price.to_f
  end
end
