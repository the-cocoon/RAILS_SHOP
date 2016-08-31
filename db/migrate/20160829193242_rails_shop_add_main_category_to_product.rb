class RailsShopAddMainCategoryToProduct < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.integer :ym_main_shop_category
    end
  end
end
