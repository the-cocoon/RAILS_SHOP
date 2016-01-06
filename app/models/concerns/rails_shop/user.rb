# include ::RailsShop::User
module RailsShop
  module User
    extend ActiveSupport::Concern

    included do
      has_many :products
      has_many :shop_categories
      has_many :shop_brands
      has_many :delivery_types
      has_many :carts

      # def actual_email
      #   return '' if email.match(/open-cook.ru/mix)
      #   email
      # end
    end # included

    def rails_shop_admin?
      self.admin?
    end
  end # User
end # RailsShop
