class CartsController < RailsShopController
  layout 'rails_shop_layout'

  before_action :find_cart_by_cart_id, only: %w[
    add_product remove_product
  ]

  before_action :find_cart_by_id, only: %w[
    amount_decrement amount_increment
    set_delivery_type
  ]

  before_action :find_product, only: %w[
    add_product remove_product
    amount_decrement amount_increment
  ]

  before_action :authenticate_user!, except: %w[
    show
    set_delivery_type
    add_product remove_product
    amount_increment amount_decrement
    reset
  ]

  before_action :shop_admin_required, except: %w[
    index show
    set_delivery_type
    add_product remove_product
    amount_increment amount_decrement
    reset destroy
  ]

  before_action :set_cart,       only: %w[ destroy ]
  before_action :owner_required, only: %w[ destroy ]

  # PUBLIC AREA

  def index
    @carts = current_user.carts.max2min(:created_at).simple_sort(params).pagination(params)
  end

  def show
    @cart = Cart.where(uid: params[:id]).first || @cart
  end

  def set_delivery_type
    if dt = DeliveryType.where(id: params[:delivery_type_id]).first
      @cart.cart_items.deliveries.destroy_all
      @cart.cart_items.create(item: dt)
      return redirect_to :back, notice: 'Изменен вариант доставки'
    end

    redirect_to :back, notice: 'Не удалось сменить варинт доставки'
  end

  def add_product
    @cart.cart_items.create(item: @product, amount: 1, price: @product.active_price)
    @cart.increment!(:cart_items_counter)

    ::CartService.add_default_delivery_if_need(@cart)
    ::RailsShopLogger.product_added_to_cart(@cart.id, @product.id)

    redirect_to :back, notice: 'Товар помещен в корзину'
  end

  def remove_product
    @cart.cart_items.where(item: @product).destroy_all
    @cart.decrement!(:cart_items_counter)

    ::CartService.delete_cart_if_need(@cart, cookies)
    ::RailsShopLogger.product_removed_from_cart(@cart.id, @product.id)

    redirect_to :back, notice: 'Товар удален из корзины'
  end

  def amount_increment
    cart_item = @cart.cart_items.where(item: @product).first

    if cart_item.amount < @product.amount
      cart_item.update(amount: cart_item.amount.next)
      redirect_to :back, notice: 'Количество данного товара в корзине увеличено'
    else
      redirect_to :back, notice: 'Количество данного товара в корзине достигло максимального значения'
    end
  end

  def amount_decrement
    cart_item = @cart.cart_items.where(item: @product).first

    if cart_item.amount > 1
      cart_item.update(amount: cart_item.amount.pred)
      redirect_to :back, notice: 'Количество данного товара в корзине уменьшено'
    else
      redirect_to :back, notice: 'Количество данного товара в корзине достигло минимального значения'
    end
  end

  def reset
    ::CartService.reset_current_cart(cookies)
    redirect_to shop_path, notice: 'Корзина очищена'
  end

  # RESTRICTED AREA

  def manage
    @carts = Cart.filled.max2min(:created_at).simple_sort(params).pagination(params)
  end

  def destroy
    @cart = Cart.find_by_uid params[:id]
    @cart.destroy
    redirect_to :back, notice: 'Корзина удалена'
  end

  private

  def set_cart
    @cart = Cart.find_by_uid params[:id]
    @owner_check_object = @cart
  end

  def find_cart_by_id
    @cart = ::CartService.define_cart(params[:id], current_user, cookies)
    page_404 unless @cart
  end

  def find_cart_by_cart_id
    @cart = ::CartService.define_cart(params[:cart_id], current_user, cookies)
    page_404 unless @cart
  end

  def find_product
    @product = Product.friendly_first(params[:product_id])
    page_404 unless @product
  end
end
