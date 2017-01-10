@OrderPaymentButton = do ->
  init: ->
    btn = $ '.js-order-payment-button'
    return false unless btn.length

    checked_payment_type = $('.js-payment-type-option:checked')

    if checked_payment_type.length

      text = checked_payment_type.data('payment-description')
      $('.js-payment-type-description').html text
      btn.prop('disabled', false)

    $('.js-payment-type-option').on 'change', (e) ->
      option = $ e.target

      text = option.data('payment-description')
      $('.js-payment-type-description').html text
      btn.prop('disabled', false)
