class RailsShopCreateDeliveryAddresses < ActiveRecord::Migration
  def change
    create_table :delivery_addresses, force: :cascade do |t|
      t.string   :title,            limit: 255,   default: ''

      t.string   :email,            limit: 255,   default: ''
      t.string   :phone,            limit: 255,   default: ''
      t.string   :full_name,        limit: 255,   default: ''
      t.string   :country,          limit: 255,   default: ''
      t.string   :region,           limit: 255,   default: ''
      t.string   :city,             limit: 255,   default: ''
      t.string   :postcode,         limit: 255,   default: ''
      t.string   :street,           limit: 255,   default: ''
      t.string   :house_number,     limit: 255,   default: ''

      t.text     :delivery_comment, limit: 65535

      t.timestamps null: false
    end
  end
end