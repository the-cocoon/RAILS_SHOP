class RailsShopSetDefaultAmountProductCartOrder < ActiveRecord::Migration
  def up
    change_column :products,    :amount, :integer, default: 0, null: false
    change_column :cart_items,  :amount, :integer, default: 0, null: false
    change_column :order_items, :amount, :integer, default: 0, null: false
  end
end
