category_rel_name = @category.class.name.tableize
categories_count  = @item.send(category_rel_name).count

json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Позиция назначена в раздел Каталога"
}

json.set! :html_content, {
  set_html: {
    ".js--#{ category_rel_name.dasherize }--count" => categories_count
  }
}