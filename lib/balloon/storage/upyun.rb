module Balloon
  module Storage
    class Upyun < Balloon::Storage::Store

      conn_option do
        {
          url: conn_url,
          headers: conn_headers,
          timeout: @uploader.upyun_timeout
        }
      end

      token_auth do |method, path, size, date|
        "encode_canonical('#{method}', '#{path}', #{size}, '#{date}')" 
      end

      def store!
        _store_path = store_path
        cache_meta = @uploader.cache_meta
        original_file = set_upload_name

        store_original_file = ::File.join _store_path, original_file       
        cache_original_file = ::File.join @uploader.cache_path, cache_meta[:filename]
        file = ::File.new cache_original_file
        response = connection.put(store_original_file, file.read, file.size)
        raise "Connection errors" if response.nil?

        if !@uploader.upyun_is_image && @uploader.respond_to?(:uploader_size)
          @uploader.uploader_size.each do |s, o|
            store_file = ::File.join _store_path, set_upload_name(s)
            cache_file = ::File.join @uploader.cache_path, cache_meta[:basename]+ "_#{s}"+"."+ cache_meta[:extension]
            file = ::File.new cache_file
            connection.put(store_file, file.read, file.size)
          end
        end

        FileUtils.remove_dir(@uploader.cache_path)
        return { filename: original_file, basename: store_name }
      end

      def retrieve!(size_name = nil)
        if !@uploader.upyun_is_image || size_name.nil?
          path = ::File.join upload_dir, store_filename(size_name)
          @uploader.upyun_domain + "/" + path
        else
          filename = store_filename + @uploader.upyun_thumb_symbol + size_name.to_s
          path = ::File.join upload_dir, filename
          @uploader.upyun_domain + "/" + path
        end
      end

      def delete!
        _store_path = store_path
        store_original_file = ::File.join _store_path, store_filename
        response = connection.delete(store_original_file)
        if !@uploader.upyun_is_image && @uploader.respond_to?(:uploader_size)
          @uploader.uploader_size.each do |s, o|
            store_file = ::File.join _store_path, store_filename(s)
            connection.delete(store_file)
          end
        end
      end

      private

      def encode_canonical(method, path, size, date)
        options = []
        options << method
        options << path 
        options << date
        options << size 
        options << "#{Digest::MD5.hexdigest(@uploader.upyun_password)}"
        "UpYun #{@uploader.upyun_username}:#{Digest::MD5.hexdigest(options.join("&"))}"
      end

      def store_filename(size_name = nil)
        return upload_file[:basename] + "." + upload_file[:extension] if size_name == nil
        upload_file[:basename] + "_" + size_name.to_s + "." + upload_file[:extension]
      end

      def conn_url
        @uploader.upyun_api_host || "http://v0.api.upyun.com"
      end

      def conn_headers
        @uploader.upyun_headers.merge({ 'Mkdir' => 'true', 'Expect' => '', 'Date' => Time.now.httpdate })
      end

      def store_path
        ::File.join("/", @uploader.upyun_bucket, upload_dir)
      end
    end
  end
end
