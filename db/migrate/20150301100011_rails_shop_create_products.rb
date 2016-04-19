class RailsShopCreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer  :user_id

      # URL
      t.string   :slug,        default: ''
      t.string   :short_id,    default: ''
      t.string   :friendly_id, default: ''

      # BASIC DATA
      t.string  :title,      default: ''
      t.string  :sku,        default: ''
      t.string  :vendor_sku, default: ''
      t.integer :amount,     default: 0

      # PRICE
      t.decimal :eur_price, precision: 10, scale: 2
      t.decimal :usd_price, precision: 10, scale: 2
      t.decimal :rur_price, precision: 10, scale: 2

      # active currency and price for shop
      t.string  :active_currency, default: :RUR
      t.decimal :active_price, precision: 10, scale: 2

      # for control price currency converting
      t.decimal :min_active_price,  precision: 10, scale: 2
      t.decimal :max_active_price,  precision: 10, scale: 2
      # ~ PRICE

      t.integer :discount_percent,       default: 0
      t.string  :price_text, limit: 255, default: ''

      # TEXT CONTENT
      t.text :raw_intro, limit: 16777215
      t.text :intro,     limit: 16777215

      t.text :raw_content, limit: 16777215
      t.text :content,     limit: 16777215

      t.string :editor_type, default: :ckeditor
      t.text   :equipment,   default: ''

      t.boolean :novelty,    default: false
      t.integer :popularity, default: 0

      # ADDITIONAL DATA
      t.string  :special_marker,  default: ''
      t.boolean :novelty,         default: false
      t.decimal :popularity_rate, precision: 8, scale: 2

      # FULL TEXT SEARCH DATA
      t.text :fts_auto_data
      t.text :fts_manual_data

      # APP + YANDEX MARKET params

      # kilo
      t.decimal :weight, precision: 8, scale: 2

      # cm
      t.integer :dimension_x, default: 0
      t.integer :dimension_y, default: 0
      t.integer :dimension_z, default: 0
      # text variant
      t.string  :dimensions,  default: ''

      # YANDEX MARKET
      t.boolean :ym_available, default: false

      t.string  :ym_vendor,      default: ''
      t.string  :ym_model,       default: ''
      t.string  :ym_vendor_code, default: ''

      t.string  :ym_country_of_origin,     default: ''
      t.boolean :ym_manufacturer_warranty, default: false

      # Direct order with YandexMarket
      t.boolean :ym_cpa, default: false

      # Delivery types
      # https://yandex.ru/support/partnermarket/delivery.xml
      t.boolean :ym_receiving_delivery, default: false
      t.boolean :ym_receiving_pickup,   default: false
      t.boolean :ym_receiving_store,    default: false

      # http://download.cdn.yandex.net/market/market_categories.xls
      # https://yandex.ru/support/partnermarket/guides/clothes.xml
      t.string  :ym_type_prefix,     default: ''
      t.string  :ym_market_category, default: ''
      t.string  :ym_sales_notes,     default: ''
      t.string  :ya_barcode,         default: ''

      # https://yandex.ru/support/partnermarket/settings/placement.xml#placement
      t.boolean :ya_adult,        default: false
      t.boolean :ya_downloadable, default: false

      # PARAMS
      t.string  :state, default: :draft
      t.integer :show_count,  default: 0
      t.boolean :order_moderation_required, default: false

      t.datetime   :published_at
      t.timestamps null: false
    end
  end
end
