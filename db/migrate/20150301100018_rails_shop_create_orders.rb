class RailsShopCreateOrders < ActiveRecord::Migration
  def change
    create_table :orders, force: :cascade do |t|
      t.integer  :user_id,             limit: 4

      t.string   :uid,                 limit: 255,    default: ''
      t.string   :state,               limit: 255,    default: :draft

      t.string   :email,               limit: 255,    default: ''
      t.string   :phone,               limit: 255,    default: ''
      t.string   :full_name,           limit: 255,    default: ''
      t.string   :country,             limit: 255,    default: ''
      t.string   :region,              limit: 255,    default: ''
      t.string   :city,                limit: 255,    default: ''
      t.string   :postcode,            limit: 255,    default: ''
      t.string   :street,              limit: 255,    default: ''
      t.string   :house_number,        limit: 255,    default: ''
      t.text     :delivery_comment,    limit: 65535

      t.string   :track_site,          limit: 255,    default: ''
      t.string   :track_code,          limit: 255,    default: ''

      t.decimal  :products_price,      precision: 10, scale: 2
      t.decimal  :delivery_price,      precision: 10, scale: 2
      t.decimal  :discount,            precision: 10, scale: 2
      t.decimal  :price_correction,    precision: 10, scale: 2
      t.decimal  :total_price,         precision: 10, scale: 2

      t.integer  :order_items_counter, limit: 4, default: 0
      t.timestamps null: false
    end
  end
end