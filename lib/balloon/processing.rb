require 'mini_magick'

module Balloon
  module Processing
    extend ActiveSupport::Concern

    def image_processing(image)
      data = {}
      ext = image.extension

      if respond_to?(:uploader_type_format)
        ext = uploader_type_format
      end

      processed_img = handle_original(image, ext)
      data[:original] = get_image_data(processed_img)

      total_size = handle_resize(image, ext, data)
      data[:total_size] = processed_img.size.to_i + total_size.to_i

      mime_type = FileExtension.get_mime_type(processed_img.type)
      extension = FileExtension.get_extension(mime_type)
      filename = "#{image.basename}.#{extension}"

      return {
        basename: image.basename,
        width: processed_img.width,
        height: processed_img.height,
        size: processed_img.size,
        filename: filename,
        mime_type: mime_type,
        extension: extension,
        data: data
      }
    end

    def handle_original(file, ext)
      original_image =  MiniMagick::Image.open(file.path)
      convert = MiniMagick.convert
      convert << file.path

      auto_orient!(original_image, convert)
      convert.format ext

      cache_file = File.join(cache_path, "#{file.basename}.#{ext}")
      convert << cache_file
      convert.call

      return MiniMagick::Image.open(cache_file)
    end

    def handle_resize(file, ext, data)
      return unless self.respond_to?(:uploader_size)
      return if store_storage.to_s == "upyun" && upyun_is_image
      total_size = 0

      uploader_size.each do |size, o|
        img = MiniMagick::Image.open(file.path)
        raise ProcessError, "process error" unless img

        convert = MiniMagick.convert
        convert << file.path

        auto_orient!(img, convert)
        convert.format ext

        resize(convert, img, o)
        cache_file = File.join(cache_path, "#{file.basename}_#{size}.#{ext}")
        convert << cache_file
        convert.call

        processed_img = MiniMagick::Image.open(cache_file)
        data[size] = get_image_data(processed_img)
        total_size += processed_img.size
      end

      return total_size
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
        return
      end

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

    def shave(convert, image)
      w, h = image[:width], image[:height]

      if w > h
        shave_off = ((w - h) / 2).round
        convert.shave "#{shave_off}x0"
        return
      end

      shave_off = ((h - w) / 2).round
      convert.shave "0x#{shave_off}"
    end

    def auto_orient!(img, covert)
      if img.exif["Orientation"].to_i > 1
        convert.auto_orient
      end
    end

    def get_image_data(img)
      return {
        width: img.width,
        height: img.height,
        size: img.size
      }
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
