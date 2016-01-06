# include RailsShop::OrderStates
module RailsShop
  module OrderDeliveryValidations
    extend ActiveSupport::Concern

    # ([[:word:]]+)@([[:word:]]+)\.([[:word:]]+)
    # /\A[^@]+@[^@]+\z/
    EMAIL_REGEXP = /@/

    included do
      attr_accessor :processing_step

      validates :phone, :full_name, :delivery_comment, presence: true, if: :local_validation_required?
      validates :phone, :full_name, :delivery_comment, presence: true, if: :pickup_validation_required?

      validates :phone, :full_name, :postcode, :city, :street, :house_number,           presence: true, if: :domestic_validation_required?
      validates :phone, :full_name, :country, :postcode, :city, :street, :house_number, presence: true, if: :forein_validation_required?
      validates :phone, :full_name, :country, :postcode, :city, :street, :house_number, presence: true, if: :special_validation_required?

      validates_format_of :email, with: EMAIL_REGEXP, if: ->(o){ o.email.present? }, message: 'Вероятно, ошибка формата'

      def has_valid_email?
        email.present? && email.match(EMAIL_REGEXP)
      end

      def completion_step?
        processing_step.to_s == 'completion'
      end

      def local_validation_required?
        completion_step? && delivery.local?
      end

      def pickup_validation_required?
        completion_step? && delivery.pickup?
      end

      def domestic_validation_required?
        completion_step? && delivery.domestic?
      end

      def forein_validation_required?
        completion_step? && delivery.forein?
      end

      def special_validation_required?
        completion_step? && delivery.special?
      end
    end # included

  end # OrderDeliveryValidations
end # RailsShop