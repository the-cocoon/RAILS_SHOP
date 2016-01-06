class CurrencyRate < ActiveRecord::Base
  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::Notifications::LocalizedErrors

  include ::RailsShop::CentralBankOfRussia
end