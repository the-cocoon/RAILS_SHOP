@OrderPaymentForm = do ->
  init: ->
    form = $ '@order-payment-form'
    return false unless form.length

    form.on 'submit', (e) ->
      e.preventDefault()

      payment_system_type = $('@payment-type-option:checked').val()
      url = form.data('payment-system-url')

      $.ajax
        type: 'GET'
        url:  url
        data:
          payment_system_type: payment_system_type
        complete: ->
          form[0].submit()

      false