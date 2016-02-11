@ShopSpoiler = do ->
  init: ->
    @inited ||= do ->
      doc = $ document

      doc.on 'click', '.js--shop-spoiler--trigger', (e) ->
        btn     = $ e.currentTarget
        holder  = btn.parents('.js--shop-spoiler--holder')
        content = holder.find('.js--shop-spoiler--content')
        content.toggle('fade')