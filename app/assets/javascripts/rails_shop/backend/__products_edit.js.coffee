@ProductsEdit = do ->
  init: ->
    @doc = $ document
    do @product_category_relation_select_init

  product_category_relation_select_init: ->
    CustomSelect.init '@product-category-relation',
      change: (select, item) ->
        $.ajax
          url: select.data('url')
          method:   'PATCH'
          dataType: 'json'
          data:
            category_id:  item.data('value')
            relation_action: item.hasClass('true')
          success: (data, status, xhr) ->
            log data, status
          error: (response, status, message) ->
            log response, status, message
