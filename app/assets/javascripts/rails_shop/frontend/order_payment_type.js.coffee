@OrderPaymentType = do ->
  init: ->
    manual_btn = $ '.js--order-payment-type--manual'

    return false unless manual_btn.length

    manual_btn.on 'click', (e) ->
      btn   = $ e.currentTarget
      form  =  btn.parents('form')
      input = form.find('[name=order_payment_type]')
      input.val('manual')
      form.submit()
      false
