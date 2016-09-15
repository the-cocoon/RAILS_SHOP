# http://xmlbeautifier.com/treeview.aspx?ControlId=XmlDocumentTextBox
xml = Builder::XmlMarkup.new(indent: 0)

xml.instruct! :xml, version: "1.0"
xml.declare! :DOCTYPE, :yml_catalog, :SYSTEM, "shops.dtd"

xml.yml_catalog(date: Time.now.strftime("%Y-%m-%d %H:%M")) do
  xml.shop do
    xml.name    'Stereo-Shop'
    xml.url     'http://stereo-shop.ru'
    xml.company 'ООО Арт Электроникс Проджект'

    xml.platform 'Profit CMS'
    xml.version  '1.0.0'
    xml.email    'zykin-ilya@ya.ru'
    # xml.agency   'IT кухня. Студия Анны Нечаевой'

    xml.currencies do
      xml.currency id: 'RUR', rate: 1
    end

    xml.cpa 1

    # PRODUCT CATEGORIES
    xml.categories do
      @categories.each do |category|
        params = { id: category.id, parentId: category.parent_id }.compact
        xml.category(params) { xml.text! category.title }
      end
    end

    # COMMON DELIVERY OPTIONS
    # xml.tag! 'delivery-options' do
    #   xml.option(cost: "250", days: "1-3")
    # end # delivery-options

    # PRODUCTS
    xml.offers do
      @products.each do |product|

        # , type: "vendor.model"
        params = { id: product.id, available: "true" }

        xml.offer(params) do
          # MUST HAVE
          xml.name        product.title
          xml.description Sanitize.fragment(product.intro.to_s).mb_chars[0...175]

          if product.has_discount?
            xml.currencyId 'RUR'
            xml.oldprice money_round(product.price).to_f
            xml.price    money_round(product.discounted_price).to_f
          else
            xml.currencyId 'RUR'
            xml.price money_round(product.price).to_f
          end

          xml.url product_url(product)

          cat_id = if product.ym_main_shop_category
            product.ym_main_shop_category
          else
            product.shop_categories.published.nested_set.last.try(:id)
          end

          xml.categoryId(cat_id) if cat_id

          xml.sales_notes "Наличные, банковская карта, б/н расчет"

          if product.main_image.present?
            # :v1024x768
            xml.picture image_url product.main_image_url(:v500x500)
          end

          # for - type: "vendor.model"
          # xml.vendor  'Noname' # BRAND
          # xml.model   'Undefined'

          # xml.cpa 1

          # RECOMENDED
          # xml.country_of_origin 'Китай'
          # xml.param(name: "Максимальный формат"){ xml.text! "A4" }
          # xml.param(name: "Потребляемая мощность", unit: "Вт") { xml.text! "1000" }

          # OPTIONAL
          xml.delivery true
          xml.pickup   true
          xml.store    false

          # PRODUCT DELIVERY OPTIONS
          # xml.tag! 'delivery-options' do
          #   xml.option(cost: "250", days: "1-3")
          # end # delivery-options

          # https://yandex.ru/support/partnermarket/elements/sales_notes.xml
          # xml.sales_notes 'Доступна Оплата online или курьеру'

          # xml.tag! 'delivery-options' do
          #   xml.option(cost: "250", days: "1-3")

          #   xml.offers do
          #     xml.offer available: true do
          #       xml.delivery true
          #       xml.pickup   true
          #     end
          #   end
          # end

          # https://yandex.ru/support/partnermarket/elements/typeprefix.xml
          # xml.typePrefix

          # xml.vendorCode '???'

          # kilos
          unless product.weight.zero?
            xml.weight product.weight.to_f.round(2)
          end

          # xml.dimensions '00/25.45/11.112'

          # Заводская гарантия?
          xml.manufacturer_warranty true

          # https://yandex.ru/support/partnermarket/guides/classification.xml
          # http://download.cdn.yandex.net/market/market_categories.xls
          if product.ym_market_category.present?
            xml.market_category product.ym_market_category
          end

          # https://yandex.ru/support/partnermarket/settings/placement.xml#placement
          # xml.downloadable '???'

          # xml.adult false
          # xml.barcode '1234567890120'
          # xml.rec '123123,1214,243' - recomended products
        end
      end
    end # offers

  end # shop
end # yml_catalog

# * !!! IMPORTANT RUR
# price_with_discount.to_
# if EUR & fix = false => цена в EUR + CUR: EUR
# if EURO is blank || fix = true

# if product.euro_price.zero?
# Нет евро цены
# if product.discount.zero?
#   # Нет скидки
#   xml.currencyId :RUR
#   xml.price product.price.to_f
# else
#   # Есть скидка
#   xml.currencyId :RUR
#   xml.oldprice product.price.to_f
#   xml.price    product.price_with_discount.to_f
# end
# else
#   # Есть евро цена
#   if product.fix_price
#     # Фиксированная цена в Рублях
#     xml.currencyId :RUR
#     xml.price product.price.to_f
#   else
#     # Цена по текущему курсу евро
#     xml.currencyId :EUR

#     if discount
#       # xml.oldprice product.euro_price.to_f
#       # xml.price product.euro_price.to_f
#     end
#   end
# end