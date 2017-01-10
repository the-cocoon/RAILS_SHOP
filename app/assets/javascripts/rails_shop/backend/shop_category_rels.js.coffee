@ShopCategoryRels = do ->
  init: ->
    @inited ||= do ->
      doc = $ document

      doc.on 'ajax:success', '.js--shop-category-rels--form, .js--shop-brand-rels--form', (xhr, data, status) ->
        JODY.processor(data)

      doc.on 'change', '.js--shop-category-rel--checkbox', (e) ->
        checkbox = $ e.target

        id    = checkbox.data('id')
        klass = checkbox.data('class')
        val   = checkbox.prop('checked')

        val = if val then 1 else 0

        # ".js--shop-caregory-rels--form"
        # ".js--shop-brand-rels--form"
        form = $(".js--#{ klass }-rels--form")
        form.find('[name=category_id]').val id
        form.find('[name=checked]').val val

        form.submit()
