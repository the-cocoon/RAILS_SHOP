@ShopCategoryRels = do ->
  init: ->
    @inited ||= do ->
      doc = $ document

      doc.on 'ajax:success', '@shop-category-rels--form, @shop-brand-rels--form', (xhr, data, status) ->
        JODY.processor(data)

      doc.on 'change', '@shop-category-rel--checkbox', (e) ->
        checkbox = $ e.target

        id  = checkbox.data('id')
        val = checkbox.prop('checked')

        val = if val then 1 else 0

        form_role = checkbox.parents('ol').data('form-role')
        form = $ "@#{ form_role }"

        form.find('[name=category_id]').val id
        form.find('[name=checked]').val val

        form.submit()
