# include RailsShop::MainImageActions
module RailsShop
  module CategoryCommonController
    extend ActiveSupport::Concern

    included do
      before_action :set_shop_category, only: %w[ show ]
      before_action :set_editable_shop_category, only: %w[ edit update destroy ]

      include ::TheSortableTreeController::Rebuild
    end # included

    def index
      # ???
    end

    def show
      @shop_category_rels =
        ::ShopCategoryRel.base_scope
          .where(category: @shop_category)

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
      @shop_categories = category_klass.for_manage.reversed_nested_set
      render template: 'rails_shop/shop_categories/manage'
    end

    def new
      @shop_category = category_klass.new
      render template: 'rails_shop/shop_categories/new'
    end

    def edit
      render template: 'rails_shop/shop_categories/edit'
    end

    def create
      @shop_category = current_user.shop_categories.new(shop_category_params)

      if @shop_category.save
        redirect_to url_for([:edit, @shop_category]), notice: 'Категория успешно создан'
      else
        render action: 'rails_shop/shop_categories/new'
      end
    end

    def update
      if @shop_category.update(shop_category_params)
        redirect_to url_for([:edit, @shop_category]), notice: 'Категоря успешно обновлена'
      else
        render action: 'rails_shop/shop_categories/edit'
      end
    end

    def destroy
      @shop_category.destroy
      redirect_to products_url
    end

    private

    def set_shop_category
      @shop_category = category_klass.published.friendly_first(params[:id])
      return page_404 unless @shop_category
    end

    def set_editable_shop_category
      @shop_category = category_klass.for_manage.friendly_first(params[:id])
      return page_404 unless @shop_category
    end

    def shop_category_params
      param_name = category_klass.table_name.singularize

      params.require(param_name).permit(
        :title,
        :url,
        :raw_intro,
        :raw_content,
        :state
      )
    end

  end
end