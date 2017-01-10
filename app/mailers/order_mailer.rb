class OrderMailer < ActionMailer::Base
  include ::RailsShop::MailerSettingsConcern
  include ::RailsShopStringBeautifiersHelper

  # Add View Helper for Mailer Preview Fix
  add_template_helper(MailerImageTagHelper)
  add_template_helper(RailsShopStringBeautifiersHelper)

  prepend_view_path "#{ ::RailsShop::Engine.root }/app/views/rails_shop"
  prepend_view_path 'views/rails_shop'

  layout 'mailers/app_layout'

  default bcc: ::Settings.rails_shop.mailer.admin_email
  default template_path: 'rails_shop/mailers/orders'

  # OrderMailer.unexpected_transition(Order.last, %w[paid draft]).deliver_now
  # OrderMailer.delay_for(2.seconds).unexpected_transition(Order.last, %w[paid draft])

  # OrderMailer.one_click('+7910001122', 'Product', '12')
  def one_click(phone, item_klass = nil, item_id = nil)
    @phone = phone

    if item_id = item_id
      klass = item_klass.constantize
      @item = klass.find(item_id)
    end

    @subject = I18n.t(:one_click, scope: %w[ rails_shop orders ], phone: phone)
    @subject = "#{ env_prefix }#{ @subject }"

    @to = ::Settings.rails_shop.mailer.admin_email

    mail(to: @to, subject: @subject)
  end

  def created(order_id)
    @order = Order.find(order_id)

    _mailer = ::Settings.rails_shop.mailer
    @from   = _mailer.smtp.default.user_name

    @subject = I18n.t(:created, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to = ::Settings.rails_shop.mailer.admin_email

    if user_email = @order.user.try(:email)
      if user_email.present? && user_email.to_s.match(/@/)
        @to = user_email
      end
    end

    mail(to: @to, subject: @subject, from: @from)
  end

  def moderation(order_id)
    @order   = Order.find(order_id)

    @subject = I18n.t(:moderation, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to  = ::Settings.rails_shop.mailer.admin_email
    @to = @order.email if @order.has_valid_email?

    mail(to: @to, subject: @subject)
  end

  def ready_to_payment(order_id)
    @order   = Order.find(order_id)

    @subject = I18n.t(:ready_to_payment, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to = ::Settings.rails_shop.mailer.admin_email
    @to = @order.email if @order.has_valid_email?

    mail(to: @to, subject: @subject)
  end

  def paid(order_id)
    @order   = Order.find(order_id)

    @subject = I18n.t(:paid, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to = ::Settings.rails_shop.mailer.admin_email
    @to = @order.email if @order.has_valid_email?

    mail(to: @to, subject: @subject)
  end

  def delivery(order_id)
    @order   = Order.find(order_id)

    @subject = I18n.t(:delivery, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to = 'admin@open-cook.ru'
    @to = @order.email if @order.has_valid_email?

    mail(to: @to, subject: @subject)
  end

  def completed(order_id)
    @order   = Order.find(order_id)

    @subject = I18n.t(:completed, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @to = ::Settings.rails_shop.mailer.admin_email
    @to = @order.email if @order.has_valid_email?

    mail(to: @to, subject: @subject)
  end

  def unexpected_transition(order_id, state_changed)
    @order = Order.find(order_id)

    @subject = I18n.t(:unexpected_transition, scope: %w[ rails_shop orders state_changed ], uid: string_in_groups_by(@order.uid.upcase))
    @subject = "#{ env_prefix }#{ @subject }"

    @state_changed = state_changed
    @to = ::Settings.rails_shop.mailer.admin_email

    mail(to: @to, subject: @subject)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # INJECT FROM APP VIEW ENGINE
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  voiceless do
    prepend_view_path "#{ ::AppViewEngine::Engine.root }/app/views"
    include ::AppViewEngine::MailerAttachments
  end
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ~ INJECT FROM APP VIEW ENGINE
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end
