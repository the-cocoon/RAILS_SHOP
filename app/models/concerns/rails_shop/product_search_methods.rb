# include ::RailsShop::ProductSearchMethods
module RailsShop
  module ProductSearchMethods
    extend ActiveSupport::Concern

    included do
      # Product.first.fts_data_rebuild!
      # FULL TEXT SEARCH by title
      def fts_data_rebuild!
        fts_data = shop_categories.map(&:title) | shop_brands.map(&:title) | [title]
        fts_data = fts_data.join ', '

        update_column :fts_auto_data, fts_data
      end
    end

    class_methods do
      # ::Product.rebuild_search_index!
      def rebuild_search_index!
        count = ::Product.count
        ::Product.all.each_with_index do |product, index|
          ::ShopItemsSearch.update(product)
          puts "#{ index }/#{ count }"
        end
      end

      # Product.fts_data_rebuild!
      def fts_data_rebuild!
        ::Product.all.each { |pr| pr.fts_data_rebuild! }
      end
    end
  end
end