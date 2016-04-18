class RailsShopAddParamsToProduct1 < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.integer :warranty_weeks, default: 0
    end
  end
end