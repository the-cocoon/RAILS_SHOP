@OrderPaymentType = do ->
  init: ->
    manual_btn = $ '.js--order-payment-type--manual'
    online_btn = $ '.js--order-payment-type--online'

    there_is_no_btns = manual_btn.length is 0 && online_btn.length is 0
    return false if there_is_no_btns

    manual_btn.on 'click', (e) ->
      btn = $ e.currentTarget
      form = btn.parents('form')
      input = form.find('[name=order_payment_type]')
      input.val('manual')
      form.submit()
      false

    online_btn.on 'click', (e) ->
      btn = $ e.currentTarget
      form = btn.parents('form')
      input = form.find('[name=order_payment_type]')
      input.val('online')
      form.submit()
      false
