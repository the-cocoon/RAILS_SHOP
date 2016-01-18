class YandexLogMailer < ActionMailer::Base
  include ::RailsShop::MailerSettingsConcern

  prepend_view_path "#{ ::RailsShop::Engine.root }/app_view/views/rails_shop"
  prepend_view_path 'app_view/views/rails_shop'
  layout 'mailers/layout'

  default bcc: ::Settings.rails_shop.mailer.admin_email
  default template_path: 'rails_shop/mailers/yandex_kassa'

  # YandexLogMailer.log_params('Check', { ... }).deliver_now
  def log_params(name, data = {})
    @name = name
    @data = data
    @data.try(:[], :params).try(:delete, :commit)

    mail(
      to:      ::Settings.rails_shop.mailer.admin_email,
      subject: "Яндекс.Касса / Платежная проверка: #{ @name }"
    )
  end
end