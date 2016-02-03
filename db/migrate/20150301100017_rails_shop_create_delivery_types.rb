class RailsShopCreateDeliveryTypes < ActiveRecord::Migration
  def change
    create_table :delivery_types, force: :cascade do |t|
      t.integer  :user_id,            limit: 4

      t.string   :title,              limit: 255, default: ''
      t.string   :delivery_kind,      limit: 255, default: :special
      t.decimal  :price,              precision: 8, scale: 2

      t.text     :raw_intro,          limit: 16777215
      t.text     :intro,              limit: 16777215

      t.text     :raw_content,        limit: 16777215
      t.text     :content,            limit: 16777215

      t.string   :editor_type,        default: :ckeditor
      t.string   :state,              limit: 255, default: :draft

      t.boolean  :default_option,     default: false
      t.boolean  :order_moderation_required, default: false

      t.timestamps null: false
    end
  end
end