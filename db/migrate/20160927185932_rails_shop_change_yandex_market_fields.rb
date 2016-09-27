class RailsShopChangeYandexMarketFields < ActiveRecord::Migration
  def change
    rename_column :products, :ya_barcode,      :ym_barcode
    rename_column :products, :ya_adult,        :ym_adult
    rename_column :products, :ya_downloadable, :ym_downloadable
  end
end
