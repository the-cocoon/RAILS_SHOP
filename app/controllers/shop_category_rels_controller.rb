class ShopCategoryRelsController < RailsShopController
  include ::TheSortableTreeController::ReversedRebuild

  before_action :user_require,   except: %w[ ]
  before_action :owner_required, except: %w[ ]
  before_action :admin_require,  except: %w[ ]

  before_action :set_category_and_item, except: %w[ rebuild ]

  def create
    checked = params[:checked].to_i == 1
    checked ? create_category_item_rels(params) : destroy_category_item_rels(params)
  end

  # Restricted area

  def create_category_item_rels params
    ::ShopCategoryRel.create(category: @category, item: @item)
    render template: 'shop_category_rels/json/create.success.json.jbuilder'
  end

  def destroy_category_item_rels params
    ::ShopCategoryRel.where(category: @category, item: @item).delete_all
    render template: 'shop_category_rels/json/destroy.success.json.jbuilder'
  end

  def set_category_and_item
    c_klass = params[:category_klass].constantize
    c_id    = params[:category_id]

    i_klass = params[:item_klass].constantize
    i_id    = params[:item_id]

    @category = c_klass.find(c_id)
    @item     = i_klass.find(i_id)
  end
end