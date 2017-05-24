module Balloon
  module Storage
    class File < Balloon::Storage::Store
      def store!
        _store_path = store_path

        if !::File.exists? _store_path
          FileUtils.mkdir_p _store_path
          FileUtils.chmod_R @uploader.dir_permissions.to_i,  _store_path
        end

        original_file = set_upload_name
        store_original_file = ::File.join _store_path, original_file
        cache_original_file = ::File.join @uploader.cache_path, @uploader.info[:filename]
        FileUtils.mv cache_original_file, store_original_file

        if @uploader.respond_to?(:uploader_size)
          @uploader.uploader_size.each do |s, o|
            store_file = ::File.join _store_path, set_upload_name(s)
            cache_file = ::File.join @uploader.cache_path, @uploader.info[:basename]+ "_#{s}"+"."+ @uploader.info[:extension]
            FileUtils.mv cache_file, store_file
          end
        end
        return { filename: original_file, basename: store_name}
      end

      def retrieve!(size_name = nil)
        return "" if !upload_file
        path = ::File.join upload_dir, store_filename(size_name)
        return "/" + path if @uploader.asset_host.nil?
        @uploader.asset_host + "/" + path
      end

      def delete!
        return false if !upload_file
        path = ::File.join store_path, store_filename
        FileUtils.rm(path) if ::File.exists?(path)
        if @uploader.respond_to?(:uploader_size)
          @uploader.uploader_size.each do |s, o|
            path = ::File.join store_path, store_filename(s)
            FileUtils.rm(path) if ::File.exists?(path)
          end
        end
      end

      private

      def store_filename(size_name = nil)
        extension = upload_file[:extension].blank? ? "" : "." + upload_file[:extension]
        if size_name.nil?
          upload_file[:basename] + extension
        else
          upload_file[:basename] + "_" + size_name.to_s + extension
        end
      end

      def store_path
        ::File.expand_path ::File.join(@uploader.root, @uploader.store_dir, upload_dir)
      end
    end
  end
end
