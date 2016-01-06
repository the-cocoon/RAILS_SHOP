class CurrencyRatesController < RailsShopController
  layout 'rails_shop_layout'

  before_action :authenticate_user!,  except: %w[ ]
  before_action :shop_admin_required, except: %w[ ]
  before_action :set_currency_rate, only: %w[ edit update destroy ]

  def manage
    @currency_rates = ::CurrencyRate.max2min(:created_at).simple_sort(params).pagination(params)
  end

  def edit; end

  def update
    @currency_rate.assign_attributes(currency_rate_params)

    if @currency_rate.save
      redirect_to url_for([:edit, @currency_rate]), notice: 'Курс успешно обновлен'
    else
      render action: 'edit'
    end
  end

  def cbr_get_rate
    current_date = Time.zone.now.strftime('%d/%m/%Y')

    ::CurrencyRate.new.tap{|o|
      o.rur_eur = o.cbr_current_eur_rate(current_date)
      o.rur_usd = o.cbr_current_usd_rate(current_date)
    }.save!

    redirect_to :back, notice: "Курсовая сводка ЦБРФ получена"
  end

  private

  def set_currency_rate
    @currency_rate = ::CurrencyRate.find(params[:id])
  end

  def currency_rate_params
    params.require(:currency_rate).permit(%w[
      rur_eur
      rur_usd
    ])
  end
end