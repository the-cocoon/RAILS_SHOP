# include RailsShop::YandexKassa
module RailsShop
  module YandexKassa
    extend ActiveSupport::Concern

    included do
      SHOP_PUBLIC_ACTIONS = %w[ yk_check yk_aviso yk_success yk_failure ]

      skip_before_action :authenticate_user!,        only: SHOP_PUBLIC_ACTIONS
      skip_before_action :shop_admin_required!,      only: SHOP_PUBLIC_ACTIONS
      skip_before_action :verify_authenticity_token, only: SHOP_PUBLIC_ACTIONS
    end

    # TEST CARD NUMBER
    # https://tech.yandex.ru/money/doc/payment-solution/examples/examples-test-data-docpage/
    #
    # 4444 4444 4444 4448
    # CVV: 000
    # DATE: any date in the future

    # YANDEX KASSA TEST
    #
    # /payments/yk/check-url
    # /payments/yk/check-url?orderNumber=e77fb23&orderSumAmount=870.00&cdd_exp_date=0216&shopArticleId=198027&paymentPayerCode=4100322062290&utf8=%3F&commit=%CE%CF%CB%C0%D2%C8%D2%DC+870+%F0%F3%E1.&paymentDatetime=2015-09-04T10%3A11%3A01.785%2B03%3A00&cdd_rrn=009111912827&external_id=deposit&paymentType=AC&requestDatetime=2015-09-04T10%3A33%3A24.411%2B03%3A00&uid=&depositNumber=7814115405c8f72f64513f07c5b81128d0922acd&nst_unilabel=1d7b576c-0009-5000-8000-000000f0d7f7&cps_user_country_code=RU&orderCreatedDatetime=2015-09-04T10%3A11%3A00.491%2B03%3A00&shopId=49138&scid=526097&shopSumBankPaycash=1003&shopSumCurrencyPaycash=10643&rebillingOn=false&orderSumBankPaycash=1003&orderSumCurrencyPaycash=10643&merchant_order_id=e77fb23_040915100932_00000_49138&cdd_pan_mask=426803%7C5624&customerNumber=123456&authenticity_token=KNc9toY6cI9fK9jR2XJJufS1yxQd2UoLBjpnq5gsYvU6qmhVYFr4AUfx3sY2lTN2aRIcDZ6oYLf8jp1gCjweUA%3D%3D&cdd_moi=e77fb23_040915100932_00000_49138&yandexPaymentId=2570015575278&cdd_eci=05&requestid=313931323131385f38353532343964633361666331656566356436343231663131623536383636306632616237336162&invoiceId=2000000576633&cdd_auth_code=908038&yandexuid=1166384471430581834&skr_env=desktop&shopSumAmount=839.55
    #
    # PHP example: https://github.com/YandexMoney/yandexmoney/blob/master/Yandex.Kassa/example%20integration/php/checkorder.php
    #
    def yk_check
      # View vars
      @check_code   = 1 # Yandex check - bad (1) by default
      @shop_id      = Settings.rails_shop.yandex_kassa.shop_id
      @req_datetime = params[:requestDatetime]
      @invoice_id   = params[:invoiceId]

      ###################################
      # Yandex.Kassa MD5 check
      ###################################
      # 0 - good, 1 - bad
      action = request.POST[:action] || 'checkOrder'
      ya_md5_result = yandex_md5_check(action, params)

      ###################################
      # Order price check
      ###################################
      # results: (:order_not_found | :incorrect_price | :correct_price)
      order_number = params[:orderNumber]
      order_sum    = params[:orderSumAmount]

      price_check_result = order_price_check(order_number, order_sum)

      ###################################
      # Order ready for sale?
      ###################################
      # true | false
      order_number = params[:orderNumber]
      ready_check_result = order_ready_check(order_number)

      ###################################
      # Result calculation
      ###################################
      if (ya_md5_result == 0) && (price_check_result == :correct_price) && ready_check_result
        # 0 is success status
        @check_code = 0
      end

      render_xml_template('payments/check_order')

      begin
        YandexLogMailer.log_params("YK CHECK - #{ params[:orderNumber].upcase }", {
          ya_md5_result: ya_md5_result,
          price_check:   price_check_result,
          ready_check:   ready_check_result,
          ya_check_code: @check_code,

          action:        action,
          params:        params,

          ssl:           request.ssl?,
          response_body: response.body,
          c_type:        response.content_type
        }).deliver_now
      rescue; end
    end

    # WE HAVE MONEY! WE HAVE TO RESERVE PRODUCTS
    #
    # /payments/yk/aviso-url
    # /payments/yk/check-url?orderNumber=e77fb23&orderSumAmount=870.00&cdd_exp_date=0216&shopArticleId=198027&paymentPayerCode=4100322062290&utf8=%3F&commit=%CE%CF%CB%C0%D2%C8%D2%DC+870+%F0%F3%E1.&paymentDatetime=2015-09-04T10%3A11%3A01.785%2B03%3A00&cdd_rrn=009111912827&external_id=deposit&paymentType=AC&requestDatetime=2015-09-04T10%3A33%3A24.411%2B03%3A00&uid=&depositNumber=7814115405c8f72f64513f07c5b81128d0922acd&nst_unilabel=1d7b576c-0009-5000-8000-000000f0d7f7&cps_user_country_code=RU&orderCreatedDatetime=2015-09-04T10%3A11%3A00.491%2B03%3A00&shopId=49138&scid=526097&shopSumBankPaycash=1003&shopSumCurrencyPaycash=10643&rebillingOn=false&orderSumBankPaycash=1003&orderSumCurrencyPaycash=10643&merchant_order_id=e77fb23_040915100932_00000_49138&cdd_pan_mask=426803%7C5624&customerNumber=123456&authenticity_token=KNc9toY6cI9fK9jR2XJJufS1yxQd2UoLBjpnq5gsYvU6qmhVYFr4AUfx3sY2lTN2aRIcDZ6oYLf8jp1gCjweUA%3D%3D&cdd_moi=e77fb23_040915100932_00000_49138&yandexPaymentId=2570015575278&cdd_eci=05&requestid=313931323131385f38353532343964633361666331656566356436343231663131623536383636306632616237336162&invoiceId=2000000576633&cdd_auth_code=908038&yandexuid=1166384471430581834&skr_env=desktop&shopSumAmount=839.55
    #
    # PHP example: https://github.com/YandexMoney/yandexmoney/blob/master/Yandex.Kassa/example%20integration/php/paymentaviso.php
    #
    def yk_aviso
      # View vars
      @check_code   = 1 # Yandex check - bad (1) by default
      @shop_id      = Settings.rails_shop.yandex_kassa.shop_id
      @req_datetime = params[:requestDatetime]
      @invoice_id   = params[:invoiceId]

      ###################################
      # Yandex.Kassa MD5 check
      ###################################
      # 0 - good, 1 - bad
      action = request.POST[:action] || 'paymentAviso'
      ya_md5_result = yandex_md5_check(action, params)

      ###################################
      # Order price check
      ###################################
      # results: (:order_not_found | :incorrect_price | :correct_price)
      order_number = params[:orderNumber]
      order_sum    = params[:orderSumAmount]

      price_check_result = order_price_check(order_number, order_sum)

      ###################################
      # Order ready for sale?
      ###################################
      # true | false
      order_number = params[:orderNumber]
      ready_check_result = order_ready_check(order_number)

      ###################################
      # Result calculation
      ###################################
      if (ya_md5_result == 0) && (price_check_result == :correct_price) && ready_check_result
        # 0 is success status
        @check_code = 0

        @order = Order.where(uid: order_number).first
        @order.process_payment_complete!
      end

      render_xml_template('payments/payment_aviso')

      begin
        YandexLogMailer.log_params("YK AVISO - #{ params[:orderNumber].upcase }", {
          ya_md5_result: ya_md5_result,
          price_check:   price_check_result,
          ready_check:   ready_check_result,
          ya_check_code: @check_code,

          action:        action,
          params:        params,

          ssl:           request.ssl?,
          response_body: response.body,
          c_type:        response.content_type
        }).deliver_now
      rescue; end
    end

    # payments/yk/success?orderNumber=1a94ea0&orderSumAmount=1450.00&cdd_exp_date=0216&shopArticleId=198027&paymentPayerCode=4100322062290&utf8=%3F&commit=%CE%CF%CB%C0%D2%C8%D2%DC+1450+%F0%F3%E1.&paymentDatetime=2015-10-06T15%3A21%3A56.489%2B03%3A00&cdd_rrn=465050309955&external_id=deposit&paymentType=AC&requestDatetime=2015-10-06T15%3A22%3A23.076%2B03%3A00&uid=&depositNumber=d1b313935909d2ab210f31179bf2861dcc169ee4&nst_unilabel=1da5d058-0009-5000-8000-00000201cdef&cps_user_country_code=RU&orderCreatedDatetime=2015-10-06T15%3A21%3A55.203%2B03%3A00&shopId=49138&scid=526097&shopSumBankPaycash=1003&shopSumCurrencyPaycash=10643&rebillingOn=false&orderSumBankPaycash=1003&orderSumCurrencyPaycash=10643&merchant_order_id=e6ce533_061015152040_00000_49138&cdd_pan_mask=426803%7C5624&customerNumber=123456&authenticity_token=wGrnw%2BLOE2sHs023Oc%2FG55QJyVqPC%2BhCMz8PpWQtZe%2BzubkwPy5DP5Cu8CubsPhNU3S84FMED9EFr6EM9iOFzQ%3D%3D&cdd_moi=e6ce533_061015152040_00000_49138&yandexPaymentId=2570017446476&cdd_eci=05&requestid=323039363731335f61393565626336633963373865383563393133333461396462386439353731343162326537666337&invoiceId=2000000603514&cdd_auth_code=306031&yandexuid=7491040441442778311&skr_env=desktop&shopSumAmount=1399.25
    #
    def yk_success
      order_uid = params[:orderNumber].to_s.downcase
      @order = Order.where(uid: order_uid).first
    end

    # /payments/yk/failure?orderNumber=1a94ea0&orderSumAmount=2400.00&cdd_exp_date=0216&shopArticleId=198027&paymentPayerCode=4100322062290&utf8=%3F&commit=%CE%CF%CB%C0%D2%C8%D2%DC+2400+%F0%F3%E1.&cdd_rrn=491778014255&external_id=deposit&paymentType=AC&requestDatetime=2015-10-06T13%3A59%3A09.280%2B03%3A00&uid=&skr_hold=false&depositNumber=44d5aad113ffea0a6709675241f1b815b5d598f4&nst_unilabel=1da5bc92-0009-5000-8000-000002010fe4&cps_user_country_code=RU&orderCreatedDatetime=2015-10-06T13%3A59%3A01.592%2B03%3A00&shopId=49138&scid=526097&shopSumBankPaycash=1003&orderN=260264d342ab4353b4850dd55e534bafe59800ef&shopSumCurrencyPaycash=10643&rebillingOn=false&orderSumBankPaycash=1003&orderSumCurrencyPaycash=10643&merchant_order_id=1a94ea0_061015135618_00000_49138&cdd_pan_mask=426803%7C5624&customerNumber=123456&authenticity_token=40sijgN25%2BiomitqBq7M22TrwwnUSWtyMt54TUPeqPftJygqWqNw01zorkFj7yST%2FdcORTBEShmuhNz3ek2X4w%3D%3D&cdd_moi=1a94ea0_061015135618_00000_49138&yandexPaymentId=2570017437687&cdd_eci=05&requestid=323039363133305f36666261363232323463626438373061393766313037316465643965326666626163643539343331&invoiceId=2000000603364&cdd_auth_code=010254&yandexuid=3518791701442689084&skr_env=desktop&shopSumAmount=2316.00
    #
    def yk_failure
      order_uid = params[:orderNumber].to_s.downcase
      @order = Order.where(uid: order_uid).first
    end

    private

    def order_ready_check order_number
      Order.where(uid: order_number).first.ready_for_sale?
    end

    def yandex_md5_check action, params
      shop_id      = Settings.rails_shop.yandex_kassa.shop_id
      shop_pass    = Settings.rails_shop.yandex_kassa.shop_password
      invoice_id   = params[:invoiceId]

      order_sum     = params[:orderSumAmount]
      order_sum_bpc = params[:orderSumBankPaycash]
      order_sum_cpc = params[:orderSumCurrencyPaycash]
      customer_num  = params[:customerNumber]

      check_str = [ action, order_sum, order_sum_cpc, order_sum_bpc, shop_id, invoice_id, customer_num, shop_pass ].join(';')
      check_md5 = Digest::MD5.hexdigest(check_str)

      (check_md5.to_s.downcase == params[:md5].to_s.downcase) ? 0 : 1
    end

    # return => :order_not_found | :incorrect_price | :correct_price
    def order_price_check order_number, order_sum
      order = Order.where(uid: order_number).first
      return :order_not_found unless order

      equal_prices  = ('%.2f' % order_sum.to_f) == ('%.2f' % order.total_price.to_f)
      return :incorrect_price unless equal_prices

      :correct_price
    end

    def render_xml_template template
      render layout: false, template: template, formats: :xml
    end
  end
end