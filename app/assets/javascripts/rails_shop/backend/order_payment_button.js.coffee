@OrderPaymentButton = do ->
  init: ->
    btn = $ '@order-payment-button'
    return false unless btn.length

    checked_payment_type = $('@payment-type-option:checked')

    if checked_payment_type.length

      text = checked_payment_type.data('payment-description')
      $('@payment-type-description').html text
      btn.prop('disabled', false)

    $('@payment-type-option').on 'change', (e) ->
      option = $ e.target

      text = option.data('payment-description')
      $('@payment-type-description').html text
      btn.prop('disabled', false)