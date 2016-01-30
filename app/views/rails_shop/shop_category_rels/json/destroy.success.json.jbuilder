category_rel_name = @category.class.name.tableize
categories_count  = @item.send(category_rel_name).count

json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Позиция удалена из раздела Каталога"
}

json.set! :html_content, {
  set_html: {
    ".js--#{ category_rel_name.dasherize }--count" => !(i_count = categories_count).zero? ? i_count : ''
  }
}