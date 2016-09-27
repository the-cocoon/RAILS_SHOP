require_relative './shop_category_fixed_pagination'

class ProductsController < RailsShopController
  before_action :authenticate_user!,   except: %w[ index show ]
  before_action :shop_admin_required!, except: %w[ index show ]

  before_action :set_product, only: [:show, :edit, :clone, :update, :destroy]

  def index
    @shop_category_rels =
      ::ShopCategoryRel.base_scope
        .select("
          MAX(shop_category_rels.id)              AS rel_id,
          MAX(shop_category_rels.item_price)      AS price,
          MAX(shop_category_rels.item_updated_at) AS updated_at,

          shop_category_rels.item_id   AS item_id,
          shop_category_rels.item_type AS item_type
        ")
        .group("
          item_id,
          item_type
        ")
        .includes(:item, item: [:attached_images])
        ._max2min(:updated_at)
        ._simple_sort(params)
        .pagination(params)

    @shop_items = @shop_category_rels.map(&:item)
    @shop_category_rels = ShopCategoryFixedPagination.new(ActiveRecord::Base.connection, params)
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
    base_products_scope = ::Product.available_for(current_user)

    @products = base_products_scope.max2min(:id)
      .simple_sort(params)
      .pagination(params)

    @products_count = base_products_scope.count
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

  def clone
    @cloned_product = @product.dup
    @cloned_product.assign_attributes(
      slug:        nil,
      short_id:    nil,
      friendly_id: nil,
      state:       :draft
    )

    # CLONE PRODUCT
    @cloned_product.save
    @cloned_product.keep_consistency_after_create!

    # CLONE CATEGORIES
    @product.shop_categories.each do |category|
      @cloned_product.shop_categories << category
    end

    @product.shop_brands.each do |brand|
      @cloned_product.shop_brands << brand
    end

    # CLONE IMAGES
    @product.attached_images.each do |image|
      image = File.open image.file.path(:original)
      @cloned_product.attached_images.create!(user: current_user, file: image)
    end

    # CLONE META DATA
    attrs = @product.meta_data.dup.attributes.with_indifferent_access
    attrs.reject! {|k, v| %w[id holder_id holder_type created_at updated_at].include? k }
    @cloned_product.meta_data.update(attrs)

    redirect_to url_for([:edit, @cloned_product]), notice: 'Успешно скопировано'
  end

  def update
    @product.assign_attributes(product_params)
    @product.content_processing_for(current_user)

    if @product.save
      @product.keep_consistency_after_update!
      # voiceless { ::ShopItemsSearch.update(@product) }

      respond_to do |format|
        format.html do
          redirect_path = polymorphic_url([:edit, @product], anchor: params[:anchor])
          redirect_to redirect_path, notice: 'Товар успешно обновлен'
        end

        format.js do
          render_json_template('rails_shop/products/json/update.success')
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.any(:js, :json) { render_json_template('rails_shop/products/json/update.errors') }
      end
    end
  end

  def destroy
    @product.destroy
    @product.keep_consistency_after_destroy!
    redirect_to manage_products_path, notice: 'Товар удален'
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

      min_price
      max_price
      discount_percent

      sku
      vendor_sku

      amount
      weight
      warranty_time_units

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

      ym_main_shop_category
      ym_market_category
      ym_sales_notes
      ym_barcode

      elco_id
      elco_markup
    ])
  end
end
