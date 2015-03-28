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
            @info
          end

          def uploader_save
            return if info.nil?
            set_storage_engine
            store_info = storage_engine.store!
            @info[:filename] = store_info[:filename]
            @info[:basename] = store_info[:basename]
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
        end

        if defined?(Mongoid)
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
            return if info.nil?
            self.file_name = info[:filename]
            self.content_type = info[:mime_type]
            self.file_size = info[:size]
            self.storage = store_storage.to_s
            self.width = info[:width]
            self.height = info[:height]
          end

          def url(size_name = nil)
           return "" if !respond_to?(:file_name) || file_name.nil?
           extension = self.file_name.to_s.match(%r"(?!\\.{1})\\w{2,}$")
           basename = self.file_name.to_s.gsub(%r"\\.{1}\\w{2,}$",'')
           @info = { basename: basename, extension: extension.to_s }
           set_storage_engine
           storage_engine.retrieve!(size_name)
          end

          def uploader_delete
           return if !respond_to?(:file_name) || file_name.nil?
           extension = self.file_name.to_s.match(%r"(?!\\.{1})\\w{2,}$")
           basename = self.file_name.to_s.gsub(%r"\\.{1}\\w{2,}$",'')
           @info = { basename: basename, extension: extension.to_s }
           set_storage_engine
           storage_engine.delete!
          end
        RUBY
      end
    end #ClassMethods
  end #Up
end
