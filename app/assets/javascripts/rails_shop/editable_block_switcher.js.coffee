@EditableBlockSwitcher = do ->
  init: ->
    @inited ||= do ->
      doc = $ document

      doc.on 'click', '@editable-block--switcher', (e) ->
        switcher = $ e.currentTarget
        holder   = switcher.parents '@editable-block'

        if holder.find('@editable-block--intro:visible').length
          holder.find('@editable-block--intro').slideUp ->
            holder.find('@editable-block--content').slideDown()
        else
          holder.find('@editable-block--content').slideUp ->
            holder.find('@editable-block--intro').slideDown()
