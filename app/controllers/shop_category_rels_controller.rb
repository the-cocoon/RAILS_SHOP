class ShopCategoryRelsController < RailsShopController
  include ::TheSortableTreeController::ReversedRebuild

  before_action :user_require,   except: %w[ ]
  before_action :owner_required, except: %w[ ]
  before_action :admin_require,  except: %w[ ]

  before_action :set_category, except: %w[ rebuild ]
  before_action :set_item,     except: %w[ rebuild ordering ]

  def create
    checked = params[:checked].to_i == 1
    checked ? create_category_item_rels(params) : destroy_category_item_rels(params)
  end

  # Restricted area

  def ordering
    @category_items =
      @category
        .shop_category_rels
        .for_manage
        .reversed_nested_set
        .pagination(params)
  end

  def create_category_item_rels params
    ::ShopCategoryRel.create(category: @category, item: @item)

    voiceless { ::ShopItemsSearch.update(@item) }

    render layout: false, template: 'shop_category_rels/json/create.success.json.jbuilder'
  end

  def destroy_category_item_rels params
    ::ShopCategoryRel.where(category: @category, item: @item).delete_all

    voiceless { ::ShopItemsSearch.update(@item) }

    render layout: false, template: 'shop_category_rels/json/destroy.success.json.jbuilder'
  end

  def set_category
    @cat_klass = params[:category_type].classify.constantize
    @category  = @cat_klass.friendly_first params[:category_id]
  end

  def set_item
    @item_klass = params[:item_type].classify.constantize
    @item       = @item_klass.friendly_first params[:item_id]
  end
end