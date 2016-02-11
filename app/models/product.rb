class Product < ActiveRecord::Base
  include ::PgSearch

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

  paginates_per 24

  # VALIDATIONS

  validates_presence_of :user, :title
  validates_presence_of :slug, if: ->{ errors.blank? }
  validates :sku, uniqueness: true, if: ->{ sku.present? }

  include ::FriendlyIdPack::Base

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

  scope :in_stock, ->{ where('amount > 0') }

  pg_search_scope :psql_search_base, against: %w[ title intro content ]

  scope :psql_search_simple, -> (term) {
    where(
      "products.title   @@ :text OR
       products.intro   @@ :text OR
       products.content @@ :text",
       text: term
    )
  }

  # SERVICE METHODS

  def params_card
    shop_params_card
  end

  # Product.first.fts_data_rebuild!
  def fts_data_rebuild!
    fts_data = shop_categories.map(&:title) | shop_brands.map(&:title) | [title]
    fts_data = fts_data.join ', '

    self.update_column :fts_auto_data, fts_data
  end

  # ::Product.rebuild_search_index!
  def self.rebuild_search_index!
    count = ::Product.count
    ::Product.all.each_with_index do |product, index|
      ShopItemsSearch.update_index(product)
      puts "#{ index }/#{ count }"
    end
  end

  # Product.fts_data_rebuild!
  def self.fts_data_rebuild!
    ::Product.all.each { |pr| pr.fts_data_rebuild! }
  end

  # Product.recalc_actual_price!
  def self.recalc_actual_price!
    ::Product.where.not(eur_price: nil).each{|pr| pr.recalc_actual_price! }
    ::Product.where.not(usd_price: nil).each{|pr| pr.recalc_actual_price! }
  end

  def recalc_actual_price!
    curr_rate = ::CurrencyRate.max2min(:created_at).first
    return unless curr_rate

    if eur_price.to_f > 0
      update_attribute(:active_price, eur_price.to_f * curr_rate.rur_eur.to_f)

    elsif usd_price.to_f > 0
      update_attribute(:active_price, usd_price.to_f * curr_rate.rur_usd.to_f)
    else
      update_attribute(:active_price, rur_price.to_f)
    end
  end

  def total_price
    active_price.to_f - (active_price.to_f/100)*discount_percent
  end

  def active_price_with_discount
    active_price.to_f - (active_price.to_f/100)*discount_percent
  end
end
