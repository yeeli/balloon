module Balloon
  module Up
    extend ActiveSupport::Concern

    included do
      include Balloon::Uploader
      include Balloon::Validate
    end

    module ClassMethods
      def uploader(name, db = nil)

        before_create :uploader_save

        class_eval <<-RUBY
          def #{name}=(file)
            save_to_cache(file)
          rescue DownloadError => e
            @download_error = e
          rescue ProcessError => e
            @process_error = e
          end

          def #{name}
            @meta
          end

          def uploader_save
            return if cache_meta.nil?
            set_storage_engine
            store_info = storage_engine.store!
            @meta[:filename] = store_info[:filename]
            @meta[:basename] = store_info[:basename]
          end

          def uploader_name
            "#{name}".pluralize
          end
        RUBY

        set_keyword if db

        validates_download_of name
      end

      def set_keyword
        if defined?(MongoMapper)
          key :file_name, String
          key :width, Integer
          key :height, Integer
          key :content_type, String
          key :file_size, Integer
          key :storage, String
          key :created_at
        elsif defined?(Mongoid)
          field :file_name, type: String
          field :width, type: Integer
          field :height, type: Integer
          field :content_type, type: String
          field :file_size, type: String
          field :storage, type: String
          field :created_at
        end

        before_create :save_db
        after_destroy :uploader_delete

        class_eval <<-RUBY
          def save_db
            return if meta.nil?
            self.file_name = meta[:filename]
            self.content_type = meta[:mime_type]
            self.file_size = meta[:size]
            self.storage = store_storage.to_s
            self.width = meta[:width]
            self.height = meta[:height]
          end

          def url(size_name = nil)
           return "" if !respond_to?(:file_name) || file_name.nil?
           extension = self.file_name.to_s.match(%r"(?!\\.{1})\\w{2,}$")
           basename = self.file_name.to_s.gsub(%r"\\.{1}\\w{2,}$",'')
           @meta = { basename: basename, extension: extension.to_s }
           set_storage_engine
           storage_engine.retrieve!(size_name)
          end

          def uploader_delete
           return if !respond_to?(:file_name) || file_name.nil?
           extension = self.file_name.to_s.match(%r"(?!\\.{1})\\w{2,}$")
           basename = self.file_name.to_s.gsub(%r"\\.{1}\\w{2,}$",'')
           @meta = { basename: basename, extension: extension.to_s }
           set_storage_engine
           storage_engine.delete!
          end
        RUBY
      end
    end #ClassMethods
  end #Up
end
