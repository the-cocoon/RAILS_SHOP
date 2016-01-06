class ShopBrandsController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  before_action :set_shop_brand, only: %w[ show ]
  before_action :set_editable_shop_brand, only: %w[ edit update destroy ]

  include ::TheSortableTreeController::Rebuild

  def index
    @shop_brands =
      ::ShopBrand
        .nested_set
        .published
        .simple_sort(params)
        .pagination(params)
  end

  def show
    @shop_category = @shop_brand

    @shop_category_rels =
      ::ShopCategoryRel
        .where(category: @shop_category)
        .in_stock
        .published
        .max2min(:id)
        .includes(:item)
        .simple_sort(params)
        .pagination(params)

    @shop_items = @shop_category_rels.map(&:item)

    render template: 'rails_shop/shop_categories/show'
  end

  # RESTRICTED AREA

  def manage
    @shop_brands = ShopBrand.for_manage.nested_set
  end

  def new
    @shop_brand = ShopBrand.new
  end

  def edit; end

  def create
    @shop_brand = current_user.shop_brands.new(shop_brand_params)

    if @shop_brand.save
      redirect_to url_for([:edit, @shop_brand]), notice: 'Бренд успешно создан'
    else
      render action: 'new'
    end
  end

  def update
    if @shop_brand.update(shop_brand_params)
      redirect_to url_for([:edit, @shop_brand]), notice: 'Бренд успешно обновлена'
    else
      render action: 'edit'
    end
  end

  def destroy
    @shop_brand.destroy
    redirect_to products_url
  end

  private

  def set_shop_brand
    @shop_brand = ShopBrand.published.friendly_first(params[:id])
    return page_404 unless @shop_brand
  end

  def set_editable_shop_brand
    @shop_brand = ShopBrand.for_manage.friendly_first(params[:id])
    return page_404 unless @shop_brand
  end

  def shop_brand_params
    params.require(:shop_brand).permit(
      :title,
      :url,
      :raw_intro,
      :raw_content,
      :state
    )
  end
end
