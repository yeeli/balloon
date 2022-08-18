module Balloon
  module Uploader
    extend ActiveSupport::Concern

    included do
      include Balloon::Configuration
      include Balloon::Processing
      include Balloon::Cache
      include Balloon::Download
      attr_accessor :file
      attr_reader :storage_engine
      attr_reader :cache_meta, :meta
      attr_accessor :download_error, :process_error
    end

    def set_storage_engine
      @storage_engine = eval(Balloon::Base::STORAGE_EGINE[store_storage.to_sym]).new(self) if !respond_to?(:@storage_engine)
    end

    def save_to_cache(up_file)
      upload_data = {}
      uploader_file = up_file

      if up_file.is_a?(String) && up_file.include?("://")
        upload_data[:remote_url] = up_file
        uploader_file = down_url(up_file)
      end

      if up_file.is_a?(ActionDispatch::Http::UploadedFile)
        upload_data[:original_filename] = up_file.original_filename
      end

      uploader_file_ext = Balloon::FileExtension.new(uploader_file)
      file_mime_type = uploader_file_ext.mime_type

      if self.respond_to?(:uploader_mimetype_white)
        if !uploader_mimetype_white.include?(file_mime_type)
          raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
        end
      end

      if self.respond_to?(:uploader_mimetype_black)
        if !uploader_mimetype_black.include?(file_mime_type)
          raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
        end
      end

      generate_cache_directory
      up_file = uploader_file_ext.save_to cache_path, permissions
      @cache_meta = image_processing up_file
      @meta = {
        width: @cache_meta[:width],
        height: @cache_meta[:height],
        size: @cache_meta[:size],
        mime_type: @cache_meta[:mime_type],
        extension: @cache_meta[:extension],
        upload_data: upload_data,
        data: upload_data.merge(@cache_meta[:data])
      }
    end

    def url(size_name = nil); end

    module ClassMethods
      def uploader_dir(name)
        define_method "uploader_dir" do; name; end
      end

      def uploader_size(options)
        list = {}

        if options.is_a?(Hash)
          options.each do |key, value|
            list[key] = parsing_size_string(value)
          end
        else
          list[:orignal] = parsing_size_string options
        end

        define_method "uploader_size" do; list; end
      end

      def uploader_name_format(info)
        define_method "uploader_name_format" do
          name = info[:name].is_a?(Proc) ? info[:name].call(self) : info[:name].to_s
          { name: name, format: info[:format] }
        end
      end

      def uploader_type_format(ext)
        define_method "uploader_type_format" do; ext; end
      end

      def uploader_mimetype_white(list)
        raise "just choise one method" if respond_to?(:uploader_mime_type_black)
        define_method "uploader_mimetype_white" do; list; end
      end


      def uploader_mimetype_black(list)
        raise "just choise one method" if respond_to?(:uploader_mime_type_black)
        define_method "uploader_mimetype_black" do; list; end
      end
    end
  end #Uploader
end
