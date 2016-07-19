class YandexMarketController < RailsShopController
  def index
    @products = Product
      .max2min(:created_at)
      .simple_sort(params)
      .pagination(params)
  end

  def switch
    product_id = params[:yandex_market_list_id]
    checked    = params[:yandex]

    product = Product.find(product_id)
    product.update_attribute(:add_to_yandex_market, checked)

    render json: { product_id: product_id, checked: checked }
  end

  def export
    @categories = ProductCategory.published.order(:id)
    @products   = Product.on_hand.published.for_yandex_market

    stream = render_to_string(formats: :xml)

    time_stamp = Time.now.strftime("%Y.%m.%-d_%H.%M")
    send_data(stream, type: "text/xml", filename: "yandex-market-#{ time_stamp }.xml")
    # render text: stream
  end

  def product_update
    product = Product.find(params[:yandex_market_list_id]) # aka product id
    product_params = params.require(:product).permit(:elco_id, :elco_markup)
    product.update(product_params)
    render json: {
      flash: { notice: 'Товар Обновлен' }
    }
  end
end
