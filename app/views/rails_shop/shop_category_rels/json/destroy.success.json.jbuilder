category_rel_name = @category.class.name.tableize
categories_count  = @item.send(category_rel_name).count

category_name      = @category.class.name.tableize.singularize
category_name_dash = category_name.dasherize

json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Позиция удалена из раздела Каталога"
}

json.set! :html_content, {
  set_html: {
    ".js--#{ category_rel_name.dasherize }--count" => !(i_count = categories_count).zero? ? i_count : ''
  },
  props: {
    "#shop_category_#{ @category.id }" => {
      'checked' => false
    },
    "[data-#{ category_name_dash }-id=#{ @category.id }]" => {
      selected: false
    }
  }
}

json.set! :js_exec, [
  { "#{@category.class.name}RelsSelect2.update_select2" => true }
]