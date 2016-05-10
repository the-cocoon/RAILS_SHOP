# 'select2:open'
# 'select2:opening'
# 'select2:selecting'
# 'select2:close'
# 'select2:closing'
# 'select2:select'
# 'select2:change'
# 'select2:unselecting'
# 'select2:unselect'

@ShopCategoryRelsSelect2 = do ->
  update_select2: ->
    $('.js--shop-category-rels-select2').trigger('change')

  init: ->
    for select2 in $('.js--shop-category-rels-select2')
      selector = $ select2

      options     = selector.data('options') || {}
      placeholder = selector.attr('placeholder') || options.placeholder || 'Укажите нужные категории'

      selector.select2
        language:    options.language || 'ru'
        allowClear:  false
        placeholder: placeholder

      selector.on 'select2:select', (e) =>
        option = $ e.params.data.element
        form   = $('.js--shop-category-rels--form')

        form.find('[name=category_id]').val option.data('shop-category-id')
        form.find('[name=checked]').val 1

        form.submit()

      selector.on 'select2:unselect', (e) =>
        option = $ e.params.data.element
        form   = $('.js--shop-category-rels--form')

        form.find('[name=category_id]').val option.data('shop-category-id')
        form.find('[name=checked]').val 0

        form.submit()