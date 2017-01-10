module RailsShop
  module MailerSettingsConcern
    extend ActiveSupport::Concern

    class_methods do
      def smtp?
        ['smtp', 'letter_opener'].include?(::Settings.rails_shop.mailer.service)
      end
    end

    # SomeMailer.test_mail.delivery_method.settings
    included do
      if smtp?
        _mailer = ::Settings.rails_shop.mailer

        default bcc:  _mailer.admin_email
        default from: _mailer.smtp.default.user_name

        def self.smtp_settings
          ::Settings.rails_shop.mailer.smtp.default.to_h
        end
      end
    end

    private

    def env_prefix
      'DEV => ' if Rails.env.development?
    end
  end
end