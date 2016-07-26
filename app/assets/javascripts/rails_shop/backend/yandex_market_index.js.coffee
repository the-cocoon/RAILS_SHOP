@YandexMarketIndex = do ->
  init: ->
    @inited = do =>
      @doc = $ document

      @doc.on 'change', '.js--ya-market--checkbox', (e) ->
        checkbox =  $ e.target
        form = checkbox.parents('form')
        form.submit()