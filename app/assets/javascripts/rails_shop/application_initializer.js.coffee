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
  PtzTabs.init()

  AttachedImages.init()
  TheSortableTree.SortableUI.init()

  CropTool.init()

  ShopSearchForm.init()
  Notifications.init()
  Notifications.show_notifications()

  ProductsEdit.init()
  ShopCategoryRels.init()

  DeliveryTypesOptions.init()
  EditableBlockSwitcher.init()

  SocialLoginButtons.init()
  RegistrationAccordion.init()
  OrderPaymentButton.init()
  OrderPaymentForm.init()
  SectionSwitcher.init()
