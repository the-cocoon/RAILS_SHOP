toastr.options =
  "closeButton": false
  "debug":       false
  "newestOnTop": false
  "progressBar": false

  "onclick": null
  "preventDuplicates": false
  "positionClass": "toast-top-right"

  "showDuration":    "10000"
  "hideDuration":    "10000"
  "timeOut":         "10000"
  "extendedTimeOut": "10000"

  "showEasing": "swing"
  "hideEasing": "linear"
  "showMethod": "fadeIn"
  "hideMethod": "fadeOut"

$(document).on 'ready page:load', ->

  Notifications.init()
  Notifications.show_notifications()

  PtzTabs.init()
  ShopSearchForm.init()

  DeliveryTypesOptions.init()
  OrderPaymentButton.init()
  OrderPaymentForm.init()

  ShopFilterForm.init()
  ShopSpoiler.init()