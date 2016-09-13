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
      render category_template(:show)
    end

    # RESTRICTED AREA

    def manage
      @shop_categories = category_klass.for_manage.reversed_nested_set
      render category_template(:manage)
    end

    def new
      @shop_category = category_klass.new
      render category_template(:new)
    end

    def edit
      render category_template(:edit)
    end

    def create
      @shop_category = current_user.send(category_name).new(shop_category_params)

      if @shop_category.save
        redirect_to url_for([:edit, @shop_category]), notice: 'Категория успешно создан'
      else
        render category_template(:new)
      end
    end

    def update
      if @shop_category.update(shop_category_params)
        redirect_to url_for([:edit, @shop_category]), notice: 'Категоря успешно обновлена'
      else
        render category_template(:edit)
      end
    end

    def destroy
      @shop_category.destroy
      redirect_to products_url
    end

    private

    def set_shop_category
      @shop_category = category_klass.available_for(current_user).friendly_first(params[:id])
      return page_404 unless @shop_category
    end

    def set_editable_shop_category
      @shop_category = category_klass.for_manage.friendly_first(params[:id])
      return page_404 unless @shop_category
    end

    def shop_category_params
      param_name = category_name.singularize

      params.require(param_name).permit(
        :title,
        :url,
        :raw_intro,
        :raw_content,
        :state
      )
    end

    def category_name
      category_klass.name.tableize
    end

    def category_template name
      { template: "rails_shop/#{ category_name }/#{ name }" }
    end
  end
end