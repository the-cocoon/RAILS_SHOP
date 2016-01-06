class OrderItem < ActiveRecord::Base
  include ::SimpleSort::Base

  belongs_to :order
  belongs_to :item, polymorphic: true
  validates  :item_id, uniqueness: { scope: [ :order_id, :item_type ]}

  scope :products,   ->{ where(item_type: :Product) }
  scope :deliveries, ->{ where(item_type: :DeliveryType) }
end
