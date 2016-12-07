require 'net/http'

# TEST TEST
# 4111 1111 1111 1111
# 2019/12
# 123
# 3dsecure: 12345678

# include RailsShop::AlfaBankPayments
module RailsShop
  module AlfaBankPayments
    extend ActiveSupport::Concern

    ALFA_GATEWAY_URL = 'https://test.paymentgate.ru/testpayment/rest/'
    ALFA_RETURN_URL  = 'https://stereo-shop.ru/alfa_callback'

    ALFA_API_USER = 'stereo_shop-api'
    ALFA_API_PASS = 'stereo_shop'

    ALFA_AUTH_DATA = { userName: ALFA_API_USER, password: ALFA_API_PASS }

    included do; end

    def alfa_before
      order_id = params[:orderNumber]
      price = (params[:sum].to_f * 100).to_i

      unless order_ready_check(order_id)
        redirect_to alfa_failure_path(id: order_id)
      end

      data = {
        amount: price,
        orderNumber: order_id,
        returnUrl: ALFA_RETURN_URL
      }

      res = alfa_gateway('register.do', data)

      begin
        AlfaLogMailer.log_params("Alfa Bank PrePay: #{ order_id }", {
          order: order_id,
          alfa_price: price,
          price_param: params[:sum],

          response: res,
          params: params,
          ssl: request.ssl?,
        }).deliver_now
      rescue; end

      if (alfa_bank_payment_page = res['formUrl']).present?
        redirect_to alfa_bank_payment_page
      else
        redirect_to alfa_failure_path(id: order_id)
      end
    end

    def alfa_callback
      # /alfa_callback?orderId=29742882-196c-4ef2-9517-4859f6933e41
      alfa_order_id = params[:orderId]
      data = { orderId: alfa_order_id }
      res = alfa_gateway('getOrderStatus.do', data)

      begin
        AlfaLogMailer.log_params("Alfa Bank Callback", {
          alfa_order_id: alfa_order_id,
          response: res,
          params: params,
          ssl:    request.ssl?
        }).deliver_now
      rescue; end

      if res['ErrorCode'] == '0'
        order_id = res['OrderNumber']

        @order = Order.where(uid: order_id).first
        @order.process_payment_complete!

        begin
          AlfaLogMailer.log_params("Alfa Bank - ЗАКАЗ ОПЛАЧЕН", {
            alfa_order_id: alfa_order_id,
            response: res,
            params: params,
            ssl:    request.ssl?
          }).deliver_now
        rescue; end

        redirect_to alfa_success_url(id: order_id)
      else

        begin
          AlfaLogMailer.log_params("Alfa Bank - ОШИБКА ОПЛАТЫ ЗАКАЗА", {
            alfa_order_id: alfa_order_id,
            response: res,
            params: params,
            ssl:    request.ssl?
          }).deliver_now
        rescue; end

        redirect_to alfa_failure_path(id: order_id)
      end
    end

    def alfa_success
      order_uid = params[:id].to_s.downcase
      @order = Order.where(uid: order_uid).first
    end

    def alfa_failure
      order_uid = params[:id].to_s.downcase
      @order = Order.where(uid: order_uid).first
    end

    private

    def order_ready_check order_number
      Order.where(uid: order_number).first.ready_for_sale?
    end

    def alfa_gateway(action, params = {})
      params = params.merge(ALFA_AUTH_DATA)
      uri = URI(ALFA_GATEWAY_URL + action)
      res = ::Net::HTTP.post_form(uri, params)
      JSON.parse(res.body)
    end
  end
end