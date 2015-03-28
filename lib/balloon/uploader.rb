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
      attr_reader :info
      attr_accessor :download_error, :process_error
    end

    def set_storage_engine
      @storage_engine = eval(Balloon::Base::STORAGE_EGINE[store_storage.to_sym]).new(self) if !respond_to?(:@storage_engine)
    end

    def save_to_cache(up_file)
      uploader_file = if up_file.is_a?(String) && up_file.include?("://")
                        down_url(up_file) 
                      else
                        up_file
                      end
      uploader_file_ext = Balloon::FileExtension.new(uploader_file)
      file_mime_type = uploader_file_ext.mime_type

      if self.respond_to?(:uploader_mimetype_white)
        if !uploader_mimetype_white.include?(file_mime_type)          
          raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
        end
      elsif self.respond_to?(:uploader_mimetype_black)
        if !uploader_mimetype_black.include?(file_mime_type)          
          raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
        end
      end

      generate_cache_directory
      up_file = uploader_file_ext.save_to cache_path, permissions
      uploader_file = up_file
      img = resize_with_string up_file
      @info = { 
        width: img[:width],
        height: img[:height],
        size: up_file.size,
        mime_type: up_file.mime_type,
        filename: up_file.filename,  
        basename: up_file.basename,
        extension: up_file.extension 
      }
    end

    def url(size_name = nil); end

    module ClassMethods
      def uploader_dir(name)
        define_method "uploader_dir" do
          name
        end
      end

      def uploader_size(options)
        list = {}

        if options.is_a?(Hash)
          options.each do |s, o|
            list[s] = parsing_size_string o
          end
        else
          list[:orignal] = parsing_size_string options
        end

        define_method "uploader_size" do
          list
        end
      end

      def uploader_name_format(info)
        define_method "uploader_name_format" do
          name = if info[:name]
                   info[:name].call(self)
                 else
                   info[:name]
                 end
          { name: name, format: info[:format] }
        end
      end

      def uploader_mimetype_white(list)
        raise "just choise one method" if respond_to?(:uploader_mime_type_black)
        define_method "uploader_mimetype_white" do
          list
        end
      end

      def uploader_mimetype_black(list)
        raise "just choise one method" if respond_to?(:uploader_mime_type_black)
        define_method "uploader_mimetype_black" do
          list
        end
      end
    end
  end #Uploader
end
