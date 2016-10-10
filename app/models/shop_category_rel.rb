class ShopCategoryRel < ActiveRecord::Base
  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::TheSortableTree::Scopes
  include ::RailsShop::SpecialFilters

  paginates_per 24
  acts_as_nested_set scope: %w[ category_type category_id ]

  belongs_to :user
  belongs_to :category, polymorphic: true
  belongs_to :item,     polymorphic: true

  validates :category_id, uniqueness: { scope: %w[ category_type item_type item_id ] }

  scope :show_sorting, ->(params) {
    params[:sfilter] ||= 'in_stock'

    if params[:sfilter] == 'as_is'
      return
        reversed_nested_set
        .simple_sort(params)
    end

    special_filter(params)
    .simple_sort(params)
  }

  # Item Methods

  STATES = %w[ draft published deleted ]

  STATES.each do |state|
    scope state, ->{ with_state state }

    define_method "#{ state }?" do
      self.state.to_s == state.to_s
    end
  end

  # Scopes
  scope :with_state, ->(states){ where(item_state: Array.wrap(states)) if states.present? }
  scope :for_manage, ->{ with_state %w[ draft published ] }

  scope :available_for, ->(user = nil) { user.try(:admin?) ? for_manage : published }

  scope :base_scope,   ->{ in_stock.published }
  scope :in_stock,     ->{ where.not(item_amount: 0) }
  scope :out_of_stock, ->{ where(item_amount: 0) }


  voiceless_include { ::AppViewEngine::ShopCategoryRel }
end
