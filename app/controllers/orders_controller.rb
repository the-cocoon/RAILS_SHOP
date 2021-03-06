class OrdersController < RailsShopController
  layout ->{ layout_for_action }

  before_action :set_order, only: %w[
    show login_before attach_current_user_to
    completion payment recalc_price payment_system
    edit update destroy
  ]

  before_action :set_cart, only: %w[ create ]

  before_action :authenticate_user!, except: %w[
    show search create login_before attach_current_user_to
    completion payment payment_system
    one_click
  ]

  before_action :shop_admin_required!, except: %w[
    index show search create login_before attach_current_user_to
    completion payment my payment_system
    one_click
  ]

  def search
    order_uid = params[:number].to_s.downcase

    if order = Order.where(uid: order_uid).first
      redirect_to order
    else
      redirect_to :back, notice: 'Заказ с таким номером не найден'
    end
  end

  def index
    @orders = current_user.orders.max2min(:created_at).with_state(params[:state]).simple_sort(params).pagination(params)
  end

  def show; end

  # one click order
  def one_click
    cart   = put_product_in_tmp_cart
    @order = Order.create(uid: cart.uid, user: current_user)

    @order.process_cart_after_create!(cart)
    @order.update_attribute(:phone, params[:phone])

    OrderMailer.one_click(
      params[:phone],
      params[:product_klass],
      params[:product_id]
    ).deliver_now

    render layout: false, json: {
      flash:{ notice: "Ваш запрос успешно отправлен" }
    }
  end

  def create
    # create new Order
    @order = Order.create(uid: @cart.uid, user: current_user)
    @order.process_cart_after_create!(@cart)

    # clean up the Cart
    ::CartService.reset_current_cart(cookies)

    # redirect to order ot login page
    redirect_to( current_user ? order_path(@order) : login_before_order_path(@order) )
  end

  def login_before # order
  end

  def attach_current_user_to # order
    if @order.user.blank?
      @order.user = current_user
      @order.save

      @order.recalc_discount!
      @order.recalc_total_price!

      # clean up the Cart
      ::CartService.reset_current_cart(cookies)
    end

    redirect_to @order
  end

  def completion
    @order.processing_step = :completion

    if @order.update(order_contacts_params)
      @order.process_completion_step!

      if @order.ready_to_payment?
        provide_required_payment_way
      else
        redirect_to url_for(@order)
      end
    else
      render action: :show
    end
  end

  def payment; end

  def payment_system
    _type = params[:payment_system_type].to_s.upcase.to_sym
    payment_system_name = Order.ps_id_name[ _type ]
    RailsShopLogger.selected_payment_system(@order.id, payment_system_name)
    render nothing: true
  end

  # RESTRICTED

  def my
    @orders = current_user.orders
  end

  def manage
    @orders = Order.max2min(:created_at).with_state(params[:state]).simple_sort(params).pagination(params)
  end

  def edit; end

  def update
    @order.assign_attributes(order_update_params)

    if @order.save
      @order.recalc_total_price!
      redirect_path = polymorphic_url([:edit, @order])
      redirect_to redirect_path, notice: 'Заказ успешно обновлен'
    else
      render action: 'edit'
    end
  end

  def destroy
    @order.deleted!
    redirect_to :back, notice: 'Заказ удалён'
  end

  def recalc_price
    @order.recalc_price!
    redirect_to :back, notice: 'Цена пересчитана'
  end

  private

  def provide_required_payment_way
    if manual_payment?
      # Отправить Письмо Админу и пользователю
      # Нарисовать объяснительную страницу
      render 'manual_payment'
    else
      redirect_to url_for([:payment, @order])
    end
  end

  def manual_payment?
    params[:order_payment_type].to_s.downcase == 'manual'
  end

  def layout_for_action
    return 'rails_shop_login'    if %w[ login_before ].include?(action_name)
    return 'rails_shop_frontend' if %w[ payment completion manual_payment ].include?(action_name)
    super
  end

  def set_product
    klass = params[:product_klass].classify.constantize
    @product = klass.base_scope.find(params[:product_id])
  end

  def put_product_in_tmp_cart
    set_product
    cart = ::Cart.create

    cart.cart_items.create(item: @product, amount: 1, price: @product.price)
    cart.increment!(:cart_items_counter)

    ::CartService.add_default_delivery_if_need(cart)
    ::RailsShopLogger.product_added_to_cart(cart.id, @product.id)

    cart
  end

  def set_cart
    @cart = ::Cart.where(uid: params[:cart_id]).first
  end

  def set_order
    @order = Order.where(uid: params[:id].downcase).first
  end

  def order_contacts_params
    params.require(:order).permit(
      :email, :phone,
      :full_name,
      :country, :region, :city,
      :postcode, :street, :house_number,
      :delivery_comment
    )
  end

  def order_update_params
    params.require(:order).permit(
      :email, :phone,
      :full_name,
      :country, :region, :city,
      :postcode, :street, :house_number,
      :delivery_comment,
      :track_site,
      :track_code,

      :products_price,
      :delivery_price,
      :discount,
      :price_correction,
      :state
    )
  end
end
