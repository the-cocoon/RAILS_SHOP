# ::ThinkingSphinx.search("canon", star: true, indices: %w[ product_core ]).count
# ::ThinkingSphinx.search("canon", star: true, indices: %w[ admin_product_core ]).count

# ::ThinkingSphinx.search("canon", star: true, classes: [ Product ], indices: %w[ product_core ]).count
# ::ThinkingSphinx.search("canon", star: true, classes: [ Product ], indices: %w[ admin_product_core ]).count

class ShopSearchController < RailsShopController
  layout ->{ layout_for_action }

  skip_before_filter :authenticate_user!,   only: %w[ shop_search ]
  skip_before_filter :shop_admin_required!, only: %w[ shop_search ]

  def shop_search
    @sq = params[:sq].to_s.strip
    to_search = ::Riddle::Query.escape @sq

    @shop_items_0 = ::ThinkingSphinx.search(
      to_search,
      star: true,
      classes: [ Product ],
      field_weights: {
        fts_manual_data: 10,
        fts_auto_data: 7,
        title: 5,
        content: 3
      },
      per_page: 24
    )

    @shop_items_1 = ::ThinkingSphinx.search(
      to_search,
      star: false,
      classes: [ Product ],
      field_weights: { title: 10, content: 5 },
      per_page: 24
    )

    @shop_items = (@shop_items_0.count > @shop_items_1.count) ? \
                   @shop_items_0 : \
                   @shop_items_1

    if request.format.json?
      render layout: false, template: 'rails_shop/shop_search/json/shop_search'
    end
  end

  def ts_products_search
    @squery   = params[:term].to_s.strip
    to_search = ::Riddle::Query.escape @squery

    @results = ::ThinkingSphinx.search(
      to_search,
      star: true,
      classes: [ Product ],
      field_weights: { title: 10, content: 5 },
      order: "created_at DESC",
      per_page: 24
    )

    render layout: false, json: res
  end

  def layout_for_action
    return 'rails_shop_frontend' if %w[ shop_search ].include?(action_name)
    'rails_shop_backend'
  end
end