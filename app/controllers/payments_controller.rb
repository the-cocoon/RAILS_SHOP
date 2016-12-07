class PaymentsController < RailsShopController
  include ::RailsShop::YandexKassa
  include ::RailsShop::AlfaBankPayments
end
