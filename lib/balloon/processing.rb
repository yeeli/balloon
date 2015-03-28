require 'mini_magick'

module Balloon
  module Processing
    extend ActiveSupport::Concern

    def resize_with_string(file)
      width, height = "", ""
      oranginl_img = MiniMagick::Image.open(file.path)
      auto_orient!(oranginl_img, file.path)
      if self.respond_to?(:uploader_size) && !(store_storage.to_s == "upyun" && upyun_is_image)
        uploader_size.each do |s, o|
          img = MiniMagick::Image.open(file.path)
          raise ProcessError, "process error" unless img
          width = img[:width]
          height = img[:height]
          new_img = resize(img, o)
          new_img.write File.join(cache_path, "#{file.basename}_#{s}.#{file.extension}")
        end
      end
      return {width: oranginl_img[:width], height: oranginl_img[:height]}
    end

    def resize(image, size)
      width, height, symbol = size[:width], size[:height], size[:symbol]     
      if !symbol.empty? || width.match(/\%/) || height.match(/\%/)
        if width == height
          image = shave(image)
          image.resize "#{width}"
        else
          image.resize "#{width}x#{height}#{symbol}"
        end
      else
        if width == height
          image = shave(image)
          value = (width.to_f / image[:width].to_f) * 100
          image.resize "#{value}%"
        else
          if width.empty?
            value = (height.to_f / image[:height].to_f)  * 100
            image.resize "#{value}%"
          elsif height.empty?
            value = (width.to_f / image[:width].to_f)  * 100
            image.resize "#{value}%"
          else
            image.resize "#{width}x#{height}"
          end
        end
      end
      return image
    end

    def shave(image)
      w, h = image[:width], image[:height]
      if w > h
        shave_off = ((w - h) / 2).round
        image.shave "#{shave_off}x0"
      else
        shave_off = ((h - w) / 2).round
        image.shave "0x#{shave_off}"
      end 
      return image
    end

    def auto_orient!(img, file)
      if img["exif:orientation"] == "6"
        img.auto_orient
        img.write file
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
