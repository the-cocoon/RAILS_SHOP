# p o.cbr_get_range_report("12/12/2012", "14/12/2012", 'R01239').body
require_relative '../app/models/concerns/rails_shop/central_bank_of_russia'
require 'pry'

class TestClass
  include ::RailsShop::CentralBankOfRussia
end

o = TestClass.new
p o.cbr_current_eur_rate("19/12/2015")
p o.cbr_current_usd_rate("19/12/2015")