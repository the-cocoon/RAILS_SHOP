class ShopColorsController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  before_action :set_shop_category, only: %w[ show ]
  before_action :set_editable_shop_category, only: %w[ edit update destroy ]

  include ::TheSortableTreeController::Rebuild

  def index
    @shop_categories =
      ::ShopColor
        .nested_set
        .published
        .simple_sort(params)
        .pagination(params)
  end

  def show
    @shop_category = @shop_category

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
    @shop_categories = ShopColor.for_manage.nested_set
  end

  def new
    @shop_category = ShopColor.new
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
    @shop_category = ShopColor.published.friendly_first(params[:id])
    return page_404 unless @shop_category
  end

  def set_editable_shop_category
    @shop_category = ShopColor.for_manage.friendly_first(params[:id])
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
