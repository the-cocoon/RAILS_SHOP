json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Товару назначен Бренд"
}

json.set! :html_content, {
  set_html: {
    ".js--product-brands--count" => @product.shop_brands.count
  }
}
