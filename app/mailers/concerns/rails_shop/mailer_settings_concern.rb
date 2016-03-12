module RailsShop
  module MailerSettingsConcern
    extend ActiveSupport::Concern

    class_methods do
      def smtp?
        ['smtp', 'letter_opener'].include?(Settings.app.mailer.service)
      end
    end

    included do
      default from: Settings.rails_shop.mailer.admin_email

      # SomeMailer.test_mail.delivery_method.settings
      if smtp?
        def self.smtp_settings
          Settings.rails_shop.mailer.smtp.to_h
        end
      end
    end

    private

    def env_prefix
      'DEV => ' if Rails.env.development?
    end

    def default_from
      Settings.app.mailer.smtp.rails_shop.user_name if smtp?
    end
  end
end