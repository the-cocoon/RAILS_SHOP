# central bank api: http://www.cbr.ru/scripts/Root.asp?PrtId=SXML

require 'net/http'
require 'nokogiri'

# include ::RailsShop::CentralBankOfRussia
module RailsShop
  module CentralBankOfRussia
    def cbr_eur_code; 'R01239'; end
    def cbr_usd_code; 'R01235'; end

    def cbr_daily_rates_url
      'http://www.cbr.ru/scripts/XML_daily.asp'
    end

    def cbr_range_rates_url
      'http://www.cbr.ru/scripts/XML_dynamic.asp'
    end

    def cbr_get_daily_report(date = "12/12/2012")
      cbr_get_response(cbr_daily_rates_url, { date_req: date })
    end

    def cbr_current_eur_rate(date)
      report = cbr_get_daily_report(date)

      Nokogiri::XML(report.body)
        .search("Valute[ID=#{ cbr_eur_code }]")
        .children()
        .search('Value')
        .text()
        .gsub(',','.')
        .to_f
    end

    def cbr_current_usd_rate(date)
      report = cbr_get_daily_report(date)

      Nokogiri::XML(report.body)
        .search("Valute[ID=#{ cbr_usd_code }]")
        .children()
        .search('Value')
        .text()
        .gsub(',','.')
        .to_f
    end

    def cbr_get_response(url, params = {})
      uri       = URI(url)
      uri.query = URI.encode_www_form(params)
      Net::HTTP.get_response(uri)
    end

  end
end

# http://opensourceconnections.com/blog/2008/04/24/adding-timeout-to-nethttp-get_response/
# rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
# retry

# def cbr_get_range_report(date_from, date_to, currency_code)
#   params = {
#     date_req1: date_from,
#     date_req2: date_to,
#     :'VAL_NM_RQ' => currency_code
#   }
#   cbr_get_response(cbr_range_rates_url, params)
# end