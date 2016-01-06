xml.instruct! :xml, version: '1.0', encoding: 'utf-8'
xml.checkOrderResponse(
  performedDatetime: @req_datetime,
  code:              @check_code,
  invoiceId:         @invoice_id,
  shopId:            @shop_id
)
