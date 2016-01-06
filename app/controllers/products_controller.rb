class ProductsController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @shop_category_rels =
      ::ShopCategoryRel
        .in_stock
        .published
        .max2min(:id)
        .includes(:item, item: [:attached_images])
        .simple_sort(params)
        .pagination(params)

    @shop_items = @shop_category_rels.map(&:item)
  end

  def show; end

  # RESTRICTED AREA

  def realtion_category
    action   = params[:relation_action].to_s
    product  = ::Product.friendly_first(params[:id])
    category = ::ProductCategory.friendly_first(params[:category_id])

    if action == 'true'
      rel = ::ProductCategoryRel.create(
        product_id:          product.id,
        product_category_id: category.id
      )
    else
      rel = ::ProductCategoryRel.where(
        product_id:          product.id,
        product_category_id: category.id
      ).first

      rel.destroy!
    end

    render json: {
      params: {
        action: action,
        p:      product.id,
        c:      category.id,
        rel:    rel.id
      }
    }
  end

  def manage
    @products = ::Product.max2min(:id).simple_sort(params).pagination(params)
  end

  def new
    @product = ::Product.new
  end

  def edit; end

  def create
    @product = current_user.products.new(product_params)
    @product.content_processing_for(current_user)

    if @product.save
      @product.keep_consistency_after_create!
      redirect_to url_for([:edit, @product]), notice: 'Товар успешно создан'
    else
      render action: 'new'
    end
  end

  def update
    @product.assign_attributes(product_params)
    @product.content_processing_for(current_user)

    if @product.save
      @product.keep_consistency_after_update!
      redirect_to url_for([:edit, @product]), notice: 'Товар успешно обновлен'
    else
      render action: 'edit'
    end
  end

  def destroy
    @product.destroy
    @product.keep_consistency_after_destroy!
    redirect_to :back, notice: 'Товар удален'
  end

  private

  def set_product
    @product = ::Product.friendly_first(params[:id])
  end

  def product_params
    params.require(:product).permit(%w[
      title
      raw_intro
      raw_content
      equipment

      rur_price
      eur_price
      usd_price

      min_active_price
      max_active_price
      discount_percent

      sku
      vendor_sku

      amount
      weight

      dimension_x
      dimension_y
      dimension_z
      dimensions

      state
      special_marker

      ym_available
      ym_cpa

      ym_vendor
      ym_model
      ym_vendor_code

      ym_type_prefix
      ym_country_of_origin
      ym_manufacturer_warranty

      ym_receiving_delivery
      ym_receiving_pickup
      ym_receiving_store

      ym_market_category
      ym_sales_notes
      ya_barcode
    ])
  end
end
