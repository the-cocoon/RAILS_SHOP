namespace :rails_shop do
  namespace :currency_rates do
    # rake rails_shop:currency_rates:get
    task get: :environment do
      rate = CurrencyRate.new
      rate.get_cbr_current_rates
      rate.save!
    end
  end
end