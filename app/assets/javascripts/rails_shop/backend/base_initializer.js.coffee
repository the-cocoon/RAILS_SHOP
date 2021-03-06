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
  CropTool.init()
  AttachedImages.init()

  # TheStorgesSortable.init()
  # TheStoragesFileUploader.init()
  TheSortableTree.SortableUI.init()

  ShopCategoryRels.init()
  ShopCategoryRelsSelect2.init()
  ShopBrandRelsSelect2.init()

  YandexMarketIndex.init()
  ProductsManage.init()