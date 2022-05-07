require 'mini_magick'

module Balloon
  module Processing
    extend ActiveSupport::Concern

    def image_processing(image)
      ext = image.extension

      if respond_to?(:uploader_type_format)
        ext = uploader_type_format
      end

      processed_img = handle_original(image, ext)

      handle_resize(image, ext)

      mime_type = processed_img.mime_type
      extension = FileExtension.get_extension(mime_type)
      filename = "#{image.basename}.#{extension}"

      return {
        basename: image.basename,
        width: processed_img.width,
        height: processed_img.height,
        size: processed_img.size,
        filename: filename,
        mime_type: mime_type,
        extension: extension
      }
    end

    def handle_original(file, ext)
      original_image =  MiniMagick::Image.open(file.path)
      convert = MiniMagick::Tool::Convert.new
      convert << file.path

      auto_orient!(original_image, convert)
      convert.format ext

      cache_file = File.join(cache_path, "#{file.basename}.#{ext}")
      convert << cache_file
      convert.call
      
      return MiniMagick::Image.open(cache_file)
    end

    def handle_resize(file, ext)
      return unless self.respond_to?(:uploader_size)
      return if store_storage.to_s == "upyun" && upyun_is_image

      uploader_size.each do |size, o|
        img = MiniMagick::Image.open(file.path)
        raise ProcessError, "process error" unless img

        convert = MiniMagick::Tool::Convert.new
        convert << file.path

        auto_orient!(img, convert)
        convert.format ext

        resize(convert, img, o)
        cache_file = File.join(cache_path, "#{file.basename}_#{size}.#{ext}")
        convert << cache_file
        convert.call

        # img.write File.join(cache_path, "#{file.basename}_#{size}.#{ext}")
      end
    end

    def resize(convert, image, size)
      width, height, symbol = size[:width], size[:height], size[:symbol]     

      if !symbol.empty? || width.match(/\%/) || height.match(/\%/)
        if width == height
          shave(convert, image)
          convert.resize "#{width}"
        else
          convert.resize "#{width}x#{height}#{symbol}"
        end

        return
      end

      if width == height
        shave(convert, image)
        value = (width.to_f / image[:width].to_f) * 100
        convert.resize "#{value}%"
      else
        if width.empty?
          value = (height.to_f / image[:height].to_f)  * 100
          convert.resize "#{value}%"
        elsif height.empty?
          value = (width.to_f / image[:width].to_f)  * 100
          convert.resize "#{value}%"
        else
          convert.resize "#{width}x#{height}"
        end
      end

      return
    end

    def shave(convert, image)
      w, h = image[:width], image[:height]

      if w > h
        shave_off = ((w - h) / 2).round
        convert.shave "#{shave_off}x0"
      else
        shave_off = ((h - w) / 2).round
        convert.shave "0x#{shave_off}"
      end 
    end

    def auto_orient!(img, covert)
      if img.exif["Orientation"].to_i > 1
        convert.auto_orient
      end
    end

    # parseing the size string
    #
    # @return [Hash] the options for string
    module ClassMethods
      def parsing_size_string(size)
        symbol = ""
        symbol_regex = /[^\d|\!|\>|\<|\%|x|X]/
          if size.include?('x')
            if has_symbol = size.match(/[\!|\>|\<]/)
              symbol = has_symbol[0]
              size_option = size[0, 7].split("x")
            else
              size_option = size.split("x")
            end
            width, height = size_option
          else
            width, height = size, size
          end
        width = width || ""
        width = width.match(symbol_regex) ? "" : width
        height = height || ""
        height = height.match(symbol_regex) ?  "" : height
        return { width: width, height: height, symbol: symbol }
      end
    end
  end
end
