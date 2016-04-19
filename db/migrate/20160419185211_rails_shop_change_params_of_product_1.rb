class RailsShopChangeParamsOfProduct1 < ActiveRecord::Migration
  def up
    change_column :products, :dimension_x, :decimal, precision: 8, scale: 2
    change_column :products, :dimension_y, :decimal, precision: 8, scale: 2
    change_column :products, :dimension_z, :decimal, precision: 8, scale: 2

    rename_column :products, :warranty_weeks, :warranty_time_units
    change_column :products, :warranty_time_units, :decimal, precision: 8, scale: 2
  end
end