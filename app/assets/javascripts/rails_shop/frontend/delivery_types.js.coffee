@DeliveryTypesOptions = do ->
  init: ->
    $('@delivery-type--form-options input[type=radio]').change (e) ->
      radio = $ e.currentTarget
      radio.parents('form').submit()
