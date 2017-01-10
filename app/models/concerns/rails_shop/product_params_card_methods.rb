# include ::RailsShop::ProductParamsCardMethods
module RailsShop
  module ProductParamsCardMethods
    def params_card
      shop_params_card
    end

    def params_card_full_list
      return nil unless params_card

      card_klass = params_card.class
      full_list = card_klass.card_fields

      return nil unless full_list

      res = full_list.map do |field_name, field_params|
        field_name if params_card.send(field_name).present?
      end.compact

      res.present? ? res : nil
    end

    def params_card_short_list
      return nil unless params_card

      card_klass = params_card.class
      short_list = card_klass.params_short_list

      return nil unless short_list

      res = short_list.map do |field_name, field_params|
        field_name if params_card.send(field_name).present?
      end.compact

      res.present? ? res : nil
    end

    def short_list_params_for(field_name)
      params_card.class.params_short_list[field_name]
    end

    def full_list_params_for(field_name)
      params_card.class.card_fields[field_name]
    end
  end
end