class DeliveryType < ActiveRecord::Base
  include ::ImageTools
  include ::RailsShop::MainImage
  include ::RailsShop::StatesProcessing

  include ::SimpleSort::Base
  include ::Pagination::Base
  include ::Notifications::LocalizedErrors

  include ::RailsShop::ContentProcessing

  paginates_per 24

  belongs_to :user

  KINDS = %w[ forein domestic local pickup special ]

  KINDS.each do |kind|
    scope kind, ->{ where delivery_kind: kind }

    define_method "#{ kind }?" do
      self.delivery_kind.to_s == kind.to_s
    end
  end

  def moderation_required?
    order_moderation_required == true || special?
  end

  validates_inclusion_of :delivery_kind, in: KINDS
  validates_presence_of :user, :title

  scope :default_option, ->{ where(default_option: true).published.max2min(:created_at) }
end
