class RailsShopCreateShopCategories < ActiveRecord::Migration
  def change
    create_table :shop_categories do |t|
      t.integer  :user_id

      # URL
      t.string :slug,        default: ''
      t.string :short_id,    default: ''
      t.string :friendly_id, default: ''

      # BASIC
      t.string :title, default: ''

      # TEXT CONTENT
      t.text :raw_intro, limit: 16777215
      t.text :intro,     limit: 16777215

      t.text :raw_content, limit: 16777215
      t.text :content,     limit: 16777215

      t.string :editor_type, default: :ckeditor

      # NESTED SET
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth, default: 0

      # PARAMS
      t.string  :state,    default: :draft
      t.boolean :optgroup, default: false

      # COUNTERS
      t.integer :show_count, default: 0

      t.integer :products_draft_count,     default: 0
      t.integer :products_published_count, default: 0
      t.integer :products_deleted_count,   default: 0

      t.datetime   :published_at
      t.timestamps null: false
    end
  end
end
