category_rel_name = @category.class.name.tableize
categories_count  = @item.send(category_rel_name).count

json.set! :keep_alerts, true

json.set! :flash, {
  notice: "Позиция назначена в раздел Каталога"
}

json.set! :html_content, {
  set_html: {
    ".js--#{ category_rel_name.dasherize }--count" => categories_count
  },
  props: {
    "#shop_category_#{ @category.id }" => {
      'checked' => true
    }
  },
  change_attrs: {
    "[data-shop-category-id=#{ @category.id }]" => {
      selected: true
    }
  }
}

json.set! :js_exec, [
  { 'ShopCategoryRelsSelect2.update_select2' => false }
]