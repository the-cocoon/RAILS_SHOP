@ProductsManage = do ->
  init: ->
    @inited ||= do =>
      @doc = $ document

      @doc.on 'change', '.js--products-manage--update-field', (e) ->
        text_field = $ e.target
        form = text_field.parents('form')
        form.submit()

      @doc.on 'ajax:success', '.js--products-manage--update-field-form', (xhr, data, status) ->
        JODY.processor(data)