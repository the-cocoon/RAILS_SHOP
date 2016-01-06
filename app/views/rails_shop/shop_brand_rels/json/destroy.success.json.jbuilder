json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Товар откреплен от Бренда"
}

json.set! :html_content, {
  set_html: {
    ".js--product-brands--count" => !(p_count = @product.shop_brands.count).zero? ? p_count : ''
  }
}
