class Product < ActiveRecord::Base
  include ::RailsShop::StatesProcessing
  include ::RailsShop::ContentProcessing
  include ::RailsShop::ShopCategoryItemConsistency

  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::HasMetaData::Holder
  include ::TheStorages::Storage
  include ::AttachedImages::ItemModel
  include ::Notifications::LocalizedErrors

  include ::TheCommentsBase::Commentable

  voiceless_include { ::ElcoProductAddon }

  paginates_per 24

  # VALIDATIONS

  validates_presence_of :user, :title
  validates_presence_of :slug, if: ->{ errors.blank? }
  validates :sku, uniqueness: true, if: ->{ sku.present? }

  include ::FriendlyIdPack::Base

  include ::RailsShop::ProductParamsCardMethods
  include ::RailsShop::ProductSearchMethods
  include ::RailsShop::ProductPriceMethods
  include ::RailsShop::ProductHasOrNeed

  # RELATIONS

  belongs_to :user

  belongs_to :shop_params_card, polymorphic: true

  has_many :shop_category_rels, as: :item

  has_many :shop_categories,
    through: :shop_category_rels,
    source: :category, source_type: :ShopCategory

  has_many :shop_brands,
    through: :shop_category_rels,
    source: :category, source_type: :ShopBrand

  has_many :shop_colors,
    through: :shop_category_rels,
    source: :category, source_type: :ShopColor

  has_many :shop_unit_ports,
    through: :shop_category_rels,
    source: :category, source_type: :ShopUnitPort

  # SCOPES
  scope :base_scope,   ->{ in_stock.published }
  scope :in_stock,     ->{ where.not(amount: 0) }
  scope :out_of_stock, ->{ where(amount: 0) }

  scope :shop_categories_rel_items, -> (ids) {
    ::ShopCategoryRel
      .includes(:item)
      .reversed_nested_set
      .where(category_id: ids, category_type: :ShopCategory)
  }

  scope :base_scope, ->{ in_stock.published }

  voiceless_include { ::AppViewEngine::Product }
end
