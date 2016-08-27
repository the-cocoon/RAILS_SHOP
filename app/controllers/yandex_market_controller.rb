class YandexMarketController < RailsShopController
  layout ->{ 'rails_shop_backend' }

  def index
    @products = Product
      .max2min(:created_at)
      .simple_sort(params)
      .pagination(params)
  end

  def switch
    product_id = params[:id]
    checked    = params[:yandex]

    product = Product.find(product_id)
    product.update_attribute(:ym_available, checked)

    render json: { product_id: product_id, checked: checked }
  end

  def export
    @categories = ::ShopCategory.published.order(:id)
    @products   = ::Product.base_scope.for_yandex_market.order(:id)

    stream = render_to_string(layout: false, formats: :xml)

    time_stamp = Time.now.strftime("%Y.%m.%-d_%H.%M")
    send_data(stream, type: "text/xml", filename: "yandex-market-#{ time_stamp }.xml")
    # render text: stream
  end

  def export_this
    @products   = ::Product.where(id: params[:id]).order(:id)
    @categories = @products.first.shop_categories.published.order(:id)

    stream = render_to_string(layout: false, template: 'yandex_market/export', formats: :xml)

    time_stamp = Time.now.strftime("%Y.%m.%-d_%H.%M")
    send_data(stream, type: "text/xml", filename: "yandex-market-#{ time_stamp }.xml")
    # render text: stream
  end
end
