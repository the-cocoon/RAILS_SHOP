class RailsShopLoggerMailer < ActionMailer::Base
  include ::RailsShop::MailerSettingsConcern

  # Add View Helper for Mailer Preview Fix
  add_template_helper(MailerImageTagHelper)

  prepend_view_path "#{ ::RailsShop::Engine.root }/app/views/rails_shop"
  prepend_view_path 'views/rails_shop'

  layout 'mailers/app_layout'

  default bcc: ::Settings.rails_shop.mailer.admin_email
  default template_path: 'rails_shop/mailers'

  # RailsShopLoggerMailer.product_added_to_cart(Cart.last.id, Product.last.id).deliver_now
  # RailsShopLoggerMailer.delay_for(2.seconds).product_added_to_cart(cart_id, product_id)
  def product_added_to_cart(cart_id, product_id)
    @cart    = Cart.find(cart_id)
    @product = Product.find(product_id)

    @to      = ::Settings.rails_shop.mailer.admin_email
    @subject = "#{ env_prefix }LOGGER: Корзина #{ @cart.uid }"

    mail(to: @to, subject: @subject)
  end

  # RailsShopLoggerMailer.product_removed_from_cart(Cart.last.id, Product.last.id).deliver_now
  def product_removed_from_cart(cart_id, product_id)
    @cart    = Cart.find(cart_id)
    @product = Product.find(product_id)

    @to      = ::Settings.rails_shop.mailer.admin_email
    @subject = "#{ env_prefix }LOGGER: Корзина #{ @cart.uid }"

    mail(to: @to, subject: @subject)
  end

  def selected_payment_system(order_id, payment_system_name)
    @order   = Order.find(order_id)

    @to      = ::Settings.rails_shop.mailer.admin_email
    @subject = "#{ env_prefix }LOGGER: Оплата заказа #{ @order.uid }"

    @payment_system_name = payment_system_name

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