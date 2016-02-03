class RailsShopCreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items, force: :cascade do |t|
      t.integer    :order_id, limit: 4
      t.references :item, polymorphic: true

      t.integer  :amount, limit: 4
      t.decimal  :price,  precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end