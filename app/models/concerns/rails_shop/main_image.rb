module RailsShop
  module MainImage
    extend ActiveSupport::Concern

    included do
      attr_accessor :main_image_need_to_be_processed
      before_save   :set_main_image_need_to_be_processed

      before_save   :main_image_generate_file_name, if: ->(o) { o.main_image_need_to_be_processed? }
      after_commit  :main_image_build_variants

      has_attached_file :main_image,
                        default_url: "/default_images/main_image/:style/missing.jpg",
                        path:        ":rails_root/public/uploads/storages/:klass/:id/main_image/:style/:filename",
                        url:         "/uploads/storages/:klass/:id/main_image/:style/:filename"

      do_not_validate_attachment_file_type :main_image
    end # included

    def main_image_need_to_be_processed?
      main_image? && main_image_updated_at_changed?
    end

    def set_main_image_need_to_be_processed
      self.main_image_need_to_be_processed = main_image_need_to_be_processed?
      nil
    end

    def main_image_generate_file_name
      attachment = self.main_image
      file_name  = attachment.instance_read(:file_name)
      file_name  = "main-image." + ImageTools.file_ext(file_name)
      attachment.instance_write :file_name, file_name
    end

    def main_image_build_variants
      if main_image_need_to_be_processed
        src = main_image.path

        ###########################
        # VARIANTS
        ###########################

        # 16x9
        v1600x900 = main_image.path :v1600x900
        v1280x720 = main_image.path :v1280x720
        v640x360  = main_image.path :v640x360

        create_path_for_file v1600x900
        create_path_for_file v1280x720
        create_path_for_file v640x360

        # 4x3
        v1024x768 = main_image.path :v1024x768
        v800x600  = main_image.path :v800x600
        v640x480  = main_image.path :v640x480

        create_path_for_file v1024x768
        create_path_for_file v800x600
        create_path_for_file v640x480

        # 1x1
        v500x500  = main_image.path :v500x500
        v100x100  = main_image.path :v100x100

        create_path_for_file v500x500
        create_path_for_file v100x100

        ###########################
        # ~ VARIANTS
        ###########################

        # src prepare
        manipulate({ src: src, dest: src, larger_side: 1600 }) do |image, opts|
          image = auto_orient image
          image = optimize    image
          image = strip       image
          image = biggest_side_not_bigger_than(image, opts[:larger_side])
        end

        # 16x9
        manipulate({ src: src, dest: v1600x900, larger_side: 1600 }) do |image, opts|
          image = smart_rect image, 1600, 900, { repage: false }
          image
        end

        manipulate({ src: v1600x900, dest: v1280x720 }) do |image, opts|
          image = strict_resize image, 1280, 720
          image
        end

        manipulate({ src: v1280x720, dest: v640x360 }) do |image, opts|
          image = strict_resize image, 640, 360
          image
        end

        # 4x3
        manipulate({ src: src, dest: v1024x768, larger_side: 1024 }) do |image, opts|
          image = smart_rect image, 1024, 768, { repage: false }
          image
        end

        manipulate({ src: v1024x768, dest: v800x600 }) do |image, opts|
          image = strict_resize image, 800, 600
          image
        end

        manipulate({ src: v800x600, dest: v640x480 }) do |image, opts|
          image = strict_resize image, 640, 480
          image
        end

        # 1x1
        manipulate({ src: src, dest: v500x500, larger_side: 500 }) do |image, opts|
          image = to_square image, 500, { repage: false }
          image
        end

        manipulate({ src: v500x500, dest: v100x100 }) do |image, opts|
          image = to_square image, 100
          image
        end

        # recalculate src size & save
        self.main_image_need_to_be_processed = false
      end
    end

    def main_image_crop_16x9 params
      crop_params = params[:crop].symbolize_keys

      src       = main_image.path
      v1600x900 = main_image.path :v1600x900
      v1280x720 = main_image.path :v1280x720
      v640x360  = main_image.path :v640x360

      manipulate({ src: src, dest: v1600x900 }.merge(crop_params)) do |image, opts|
        scale = image[:width].to_f / opts[:img_w].to_f
        image = crop image, opts[:x], opts[:y], opts[:w], opts[:h], { scale: scale, repage: false }
        image = strict_resize image, 1600, 900
        image
      end

      manipulate({ src: v1600x900, dest: v1280x720 }) do |image, opts|
        image = strict_resize image, 1280, 720
        image
      end

      manipulate({ src: v1280x720, dest: v640x360 }) do |image, opts|
        image = strict_resize image, 640, 360
        image
      end

      main_image.url(:v1600x900, timestamp: false)
    end

    def main_image_crop_4x3 params
      crop_params = params[:crop].symbolize_keys

      src       = main_image.path
      v1024x768 = main_image.path :v1024x768
      v800x600  = main_image.path :v800x600
      v640x480  = main_image.path :v640x480

      manipulate({ src: src, dest: v1024x768 }.merge(crop_params)) do |image, opts|
        scale = image[:width].to_f / opts[:img_w].to_f
        image = crop image, opts[:x], opts[:y], opts[:w], opts[:h], { scale: scale, repage: false }
        image = strict_resize image, 1024, 768
        image
      end

      manipulate({ src: v1024x768, dest: v800x600 }) do |image, opts|
        image = strict_resize image, 800, 600
        image
      end

      manipulate({ src: v800x600, dest: v640x480 }) do |image, opts|
        image = strict_resize image, 640, 480
        image
      end

      main_image.url(:v1024x768, timestamp: false)
    end

    def main_image_crop_1x1 params
      crop_params = params[:crop].symbolize_keys

      src      = main_image.path
      v500x500 = main_image.path :v500x500
      v100x100 = main_image.path :v100x100

      manipulate({ src: src, dest: v500x500 }.merge(crop_params)) do |image, opts|
        scale = image[:width].to_f / opts[:img_w].to_f
        image = crop image, opts[:x], opts[:y], opts[:w], opts[:h], { scale: scale, repage: false }
        image = strict_resize image, 500, 500
        image
      end

      manipulate({ src: v500x500, dest: v100x100 }) do |image, opts|
        image = strict_resize image, 100, 100
        image
      end

      main_image.url(:v500x500, timestamp: false)
    end

    def main_image_rotate_left
      return false unless main_image?

      image_variants = all_image_variants.push(main_image.path)

      image_variants.each do |image_path|
        manipulate({ src: image_path, dest: image_path }) do |image, opts|
          rotate_left image
        end
      end
    end

    def main_image_rotate_right
      return false unless main_image?

      image_variants = all_image_variants.push(main_image.path)

      image_variants.each do |image_path|
        manipulate({ src: image_path, dest: image_path }) do |image, opts|
          rotate_right image
        end
      end
    end

    def all_image_variants
      [
        # 16x9
        main_image.path(:v1600x900),
        main_image.path(:v1280x720),
        main_image.path(:v640x360),

        # 4x3
        main_image.path(:v1024x768),
        main_image.path(:v800x600),
        main_image.path(:v640x480),

        # 1x1
        main_image.path(:v500x500),
        main_image.path(:v100x100)
      ]
    end

    def main_image_destroy!
      destroy_file( all_image_variants )
      main_image.destroy
      save!
    end

  end # MainImage
end # RailsShop
