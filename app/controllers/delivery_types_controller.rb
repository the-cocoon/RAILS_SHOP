class DeliveryTypesController < RailsShopController

  before_action :set_delivery_type, only: [:show, :edit, :update, :destroy] + RailsShop::MainImageActions::ACTIONS
  before_action :set_holder_for_main_image, only: RailsShop::MainImageActions::ACTIONS

  # RESTRICTED AREA

  def manage
    @delivery_types = DeliveryType.for_manage
  end

  def new
    @delivery_type = DeliveryType.new
  end

  def create
    @delivery_type = current_user.delivery_types.new(delivery_type_params)
    @delivery_type.content_processing_for(current_user)

    if @delivery_type.save
      redirect_to url_for([:edit, @delivery_type]), notice: 'Тип доставки успешно создан'
    else
      render action: 'new'
    end
  end

  def edit; end

  def update
    @delivery_type.assign_attributes(delivery_type_params)
    @delivery_type.content_processing_for(current_user)

    if @delivery_type.save
      redirect_to url_for([:edit, @delivery_type]), notice: 'Тип доставки успешно обновлен'
    else
      render action: 'edit'
    end
  end

  private

  def set_delivery_type
    @delivery_type = DeliveryType.for_manage.find(params[:id])
  end

    def set_holder_for_main_image
      @main_image_holder = @delivery_type
    end

  def delivery_type_params
    params.require(:delivery_type).permit(
      :main_image,

      :title,
      :price,

      :raw_intro,
      :raw_content,

      :default_option,
      :order_moderation_required,

      :state,
      :delivery_kind
    )
  end
end
