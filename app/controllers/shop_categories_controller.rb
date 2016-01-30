class ShopCategoriesController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ index show ]
  before_action :shop_admin_required, except: %w[ index show ]

  before_action :set_shop_category, only: [:show]
  before_action :set_editable_shop_category, only: [:edit, :update, :destroy]

  include ::TheSortableTreeController::Rebuild

  def show
    @shop_category_rels =
      ::ShopCategoryRel
        .where(category: @shop_category)
        .in_stock
        .published
        .includes(:item)
        .max2min(:id)
        .simple_sort(params)
        .pagination(params)

    @shop_items = @shop_category_rels.map(&:item)
  end

  # RESTRICTED AREA

  def manage
    @shop_categories = ::ShopCategory.for_manage.nested_set
  end

  def ordering
    @category_items = @shop_category.shop_category_item_rels.reversed_nested_set
  end

  def new
    @shop_category = ::ShopCategory.new
  end

  def edit; end

  def create
    @shop_category = current_user.shop_categories.new(shop_category_params)

    if @shop_category.save
      redirect_to url_for([:edit, @shop_category]), notice: 'Категория товаров успешно создана'
    else
      render action: 'new'
    end
  end

  def update
    if @shop_category.update(shop_category_params)
      redirect_to url_for([:edit, @shop_category]), notice: 'Категория товаров успешно обновлена'
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
    @shop_category = ::ShopCategory.available_for(current_user).friendly_first(params[:id])
    return page_404 unless @shop_category
  end

  def set_editable_shop_category
    @shop_category = ::ShopCategory.for_manage.friendly_first(params[:id])
    return page_404 unless @shop_category
  end

  def set_holder_for_main_image
    @main_image_holder = @shop_category
  end

  def shop_category_params
    params.require(:shop_category).permit(
      :title,
      :state
    )
  end
end
