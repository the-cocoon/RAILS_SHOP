# include ::RailsShop::ShopCategoryItemConsistency
module RailsShop
  module ShopCategoryItemConsistency

    def keep_consistency!
      shop_category_rels_items_consistency!
    end

    def keep_consistency_after_create!
      shop_category_rels_items_consistency_after_create!
    end

    def keep_consistency_after_update!
      shop_category_rels_items_consistency_after_update!
    end

    def keep_consistency_after_destroy!
      shop_category_rels_items_consistency_after_destroy!
    end

    # #############################
    # Product Category Item Consistency
    # #############################

    def shop_category_rels_items_consistency!
      if shop_category_rels.any?
        keep_consistency_after_update!
      else
        keep_consistency_after_create!
      end
    end

    def shop_category_rels_items_consistency_after_create!
      recalc_price!

      shop_category_rels.create(
        item: self,

        item_title: self.title,
        item_state: self.state,

        item_novelty:         self.novelty,
        item_popularity_rate: self.popularity_rate,

        item_amount:           self.amount,
        item_discount_percent: self.discount_percent,

        item_price:            self.price,
        item_discounted_price: self.discounted_price,

        item_shop_params_card_id:   self.shop_params_card_id,
        item_shop_params_card_type: self.shop_params_card_type,

        item_created_at: self.created_at,
        item_updated_at: self.updated_at
      )
    end

    def shop_category_rels_items_consistency_after_update!
      recalc_price!

      shop_category_rels.update_all(
        item_title: self.title,
        item_state: self.state,

        item_novelty:         self.novelty,
        item_popularity_rate: self.popularity_rate,

        item_amount:           self.amount,
        item_discount_percent: self.discount_percent,

        item_price:            self.price,
        item_discounted_price: self.discounted_price,

        item_shop_params_card_id:   self.shop_params_card_id,
        item_shop_params_card_type: self.shop_params_card_type,

        item_created_at: self.created_at,
        item_updated_at: self.updated_at
      )
    end

    def shop_category_rels_items_consistency_after_destroy!
      shop_category_rels.delete_all
    end

  end # ProductConsistency
end # RailsShop
