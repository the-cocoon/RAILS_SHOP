class AlfaLogMailer < ActionMailer::Base
  include ::RailsShop::MailerSettingsConcern

  prepend_view_path "#{ ::RailsShop::Engine.root }/app/views/rails_shop"
  prepend_view_path 'views/rails_shop'

  layout 'mailers/app_layout'

  default bcc: ::Settings.rails_shop.mailer.admin_email
  default template_path: 'rails_shop/mailers/alfa_payments'

  # AlfaLogMailer.log_params('Check', { ... }).deliver_now
  def log_params(name, data = {})
    @name = name
    @data = data
    @data.try(:[], :params).try(:delete, :commit)

    mail(
      to:      ::Settings.rails_shop.mailer.admin_email,
      subject: "Альфа Банк / #{ @name }"
    )
  end
end
