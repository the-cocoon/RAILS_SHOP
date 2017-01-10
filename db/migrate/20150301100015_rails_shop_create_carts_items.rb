class RailsShopCreateCartsItems < ActiveRecord::Migration
  def change
    create_table :cart_items, force: :cascade do |t|
      t.integer    :cart_id
      t.references :item, polymorphic: true

      t.integer :amount
      t.decimal :price, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end