# include RailsShop::MainImageActions
module RailsShop
  module MainImageActions

    ACTIONS = %w[
      main_image_crop_16x9
      main_image_crop_4x3
      main_image_crop_1x1
      main_image_rotate_left
      main_image_rotate_right
      main_image_delete
    ]

    def main_image_crop_16x9
      path = @main_image_holder.main_image_crop_16x9(params)
      render json: { ids: { '@main-image--v16x9' => path + rnd_num  } }
    end

    def main_image_crop_4x3
      path = @main_image_holder.main_image_crop_4x3(params)
      render json: { ids: { '@main-image--v4x3' => path + rnd_num } }
    end

    def main_image_crop_1x1
      path = @main_image_holder.main_image_crop_1x1(params)
      render json: { ids: { '@main-image--v1x1' => path + rnd_num } }
    end

    def main_image_rotate_left
      @main_image_holder.main_image_rotate_left
      redirect_to :back
    end

    def main_image_rotate_right
      @main_image_holder.main_image_rotate_right
      redirect_to :back
    end

    def main_image_delete
      @main_image_holder.main_image_destroy!
      redirect_to :back
    end

    private

    def rnd_num
      "?#{ Time.now.to_i }"
    end

  end # MainImageActions
end # RailsShop
