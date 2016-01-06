class RailsShopCreateCart < ActiveRecord::Migration
  def change
    create_table :carts, force: :cascade do |t|
      t.integer :user_id

      t.string  :uid, default: ''
      t.integer :cart_items_counter

      t.timestamps null: false
    end
  end
end