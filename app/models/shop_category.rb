class ShopCategory < ActiveRecord::Base
  include ::RailsShop::StatesProcessing
  include ::RailsShop::ContentProcessing

  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::Notifications::LocalizedErrors

  include ::TheSortableTree::Scopes
  acts_as_nested_set scope: %w[ user_id ]

  validates :title, uniqueness: true
  validates_presence_of :user, :title
  validates_presence_of :slug, if: ->{ errors.blank? }

  include ::FriendlyIdPack::Base

  paginates_per 24

  belongs_to :user

  has_many :shop_category_rels, as: :category

  has_many :products,
    through: :shop_category_rels,
    source: :item, source_type: :Product
end
