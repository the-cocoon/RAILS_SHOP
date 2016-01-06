# include RailsShop::YandexKassa
module RailsShop
  module YandexKassa
    extend ActiveSupport::Concern

    included do
      include ::RailsShop::YandexKassaPaymentActions
      # include ::RailsShop::YandexKassaTestActions
    end
  end
end