module RailsShop
  module MailerSettingsConcern
    extend ActiveSupport::Concern

    included do
      default from: Settings.rails_shop.mailer.admin_email

      def self.smtp?
        Settings.app.mailer.service == 'smtp'
      end

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

    def smtp?
      Settings.app.mailer.service == 'smtp'
    end

    def default_from
      Settings.app.mailer.smtp.rails_shop.user_name if smtp?
    end
  end
end