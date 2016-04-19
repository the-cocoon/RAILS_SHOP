# include ::RailsShop::ProductHasOrNeed
module RailsShop
  module ProductHasOrNeed
    def in_stock?
      !amount.zero?
    end

    def has_warranty_info?
      ym_manufacturer_warranty ||
      !warranty_time_units.zero?
    end

    def has_content?
      content.present?
    end

    def has_params_full_list?
      params_card_full_list
    end

    def has_gallery?
      attached_images.count > 1
    end

    def need_comments?
      true
    end

    def has_additional_info?
      dimensions.present? ||
      equipment.present?  ||
      sku.present?
    end
  end
end
