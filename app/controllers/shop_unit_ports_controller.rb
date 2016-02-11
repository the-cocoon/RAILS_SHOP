class ShopUnitPortsController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  before_action :set_shop_category, only: %w[ show ]
  before_action :set_editable_shop_category, only: %w[ edit update destroy ]

  include ::TheSortableTreeController::Rebuild

  def index
    @shop_categories =
      ::ShopUnitPort
        .in_stock
        .published
        .includes(:item)
        .max2min(:id)
        .simple_sort(params)
        .pagination(params)
  end

  def show
    @shop_category_rels =
      ::ShopCategoryRel
        .where(category: @shop_category)
        .in_stock
        .published

    @filter_types = @shop_category_rels
      .pluck(:item_shop_params_card_type)
      .uniq
      .compact

    @shop_category_rels =
      @shop_category_rels
        .includes(:item)
        .reversed_nested_set
        .simple_sort(params)
        .pagination(params)

    @shop_items = @shop_category_rels.map(&:item)

    render template: 'rails_shop/shop_categories/show'
  end

  # RESTRICTED AREA

  def manage
    @shop_categories = ShopUnitPort.for_manage.reversed_nested_set
  end

  def new
    @shop_category = ShopUnitPort.new
  end

  def edit; end

  def create
    @shop_category = current_user.shop_categories.new(shop_category_params)

    if @shop_category.save
      redirect_to url_for([:edit, @shop_category]), notice: 'Категория успешно создан'
    else
      render action: 'new'
    end
  end

  def update
    if @shop_category.update(shop_category_params)
      redirect_to url_for([:edit, @shop_category]), notice: 'Категоря успешно обновлена'
    else
      render action: 'edit'
    end
  end

  def destroy
    @shop_category.destroy
    redirect_to products_url
  end

  private

  def set_shop_category
    @shop_category = ShopUnitPort.published.friendly_first(params[:id])
    return page_404 unless @shop_category
  end

  def set_editable_shop_category
    @shop_category = ShopUnitPort.for_manage.friendly_first(params[:id])
    return page_404 unless @shop_category
  end

  def shop_category_params
    params.require(:shop_color).permit(
      :title,
      :url,
      :raw_intro,
      :raw_content,
      :state
    )
  end
end
