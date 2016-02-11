class RailsShopCreateShopCategoryRels < ActiveRecord::Migration
  def change
    create_table :shop_category_rels do |t|
      t.references :category, polymorphic: true, index: true
      t.references :item,     polymorphic: true, index: true

      # Item denormalization
      t.string :item_title, default: ''
      t.string :item_state, default: :draft # draft | published | deleted

      t.integer :item_amount,           default: 0
      t.integer :item_discount_percent, default: 0

      t.boolean :item_novelty,         default: false
      t.decimal :item_popularity_rate, precision: 8, scale: 2

      t.decimal :item_active_price,               precision: 10, scale: 2
      t.decimal :item_active_price_with_discount, precision: 10, scale: 2

      t.references :item_shop_params_card, polymorphic: true

      t.datetime :item_created_at
      t.datetime :item_updated_at
      # ~ Item denormalization

      # Nested Set
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth, default: 0

      t.timestamps null: false
    end
  end
end
