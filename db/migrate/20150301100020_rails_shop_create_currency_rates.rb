# http://www.cbr.ru/scripts/Root.asp?PrtId=SXML
# http://www.cbr.ru/scripts/XML_val.asp
# http://www.cbr.ru/scripts/XML_daily.asp
class RailsShopCreateCurrencyRates < ActiveRecord::Migration
  def change
    create_table :currency_rates, force: :cascade do |t|
      t.decimal :rur_usd, precision: 8, scale: 4
      t.decimal :rur_eur, precision: 8, scale: 4

      t.timestamps null: false
    end
  end
end