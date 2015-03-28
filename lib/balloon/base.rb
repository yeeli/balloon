module Balloon
  class Base
    include Balloon::Uploader

    def self.uploader(name)
      class_eval <<-RUBY
        def initialize(upload_file = nil)
          set_storage_engine
          @file = upload_file.is_a?(Hash) ? upload_file[:#{name}] : upload_file 
        end

        def uploader_name
          "#{name}".pluralize
        end

        def set_storage_engine
          @storage_engine = eval(STORAGE_EGINE[store_storage.to_sym]).new(self) if !respond_to?(:@storage_engine)
        end
      RUBY
    end

    # upload file save storage
    #
    # @param [File] upload_file the upload file
    def upload_store(upload_file = nil)
      uploader_file = upload_file.nil? ? @file : upload_file
      save_to_cache(uploader_file)
      store_info = storage_engine.store!
      @info[:filename] = store_info[:filename]
      @info[:basename] = store_info[:basename]
    end
    
    def from_store(size_name = nil)
      storage_engine.retrieve!(size_name)
    end

    def upload_delete
      storage_engine.delete!
    end
  end
end
