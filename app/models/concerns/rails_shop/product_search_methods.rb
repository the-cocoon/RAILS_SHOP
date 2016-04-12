# include ::RailsShop::ProductSearchMethods
module RailsShop
  module ProductSearchMethods
    # FULL TEXT SEARCH HELPERS

    # Product.first.fts_data_rebuild!
    # FULL TEXT SEARCH by title
    def fts_data_rebuild!
      fts_data = shop_categories.map(&:title) | shop_brands.map(&:title) | [title]
      fts_data = fts_data.join ', '

      self.update_column :fts_auto_data, fts_data
    end

    # ::Product.rebuild_search_index!
    def self.rebuild_search_index!
      count = ::Product.count
      ::Product.all.each_with_index do |product, index|
        ::ShopItemsSearch.update_index(product)
        puts "#{ index }/#{ count }"
      end
    end

    # Product.fts_data_rebuild!
    def self.fts_data_rebuild!
      ::Product.all.each { |pr| pr.fts_data_rebuild! }
    end
  end
end