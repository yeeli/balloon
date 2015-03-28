module Balloon
  module Storage
    class Store
      def initialize(uploader)
        @uploader = uploader
      end

      def store!; end

      def retrieve!(size_name = nil); end

      def upload_file
        file_info = @uploader.info
        return {} if file_info.nil?
        basename = file_info[:basename] || ""
        extension = file_info[:extension] || ""
        { basename: basename, extension: extension }
      end

      def upload_dir
        @uploader.respond_to?(:uploader_dir) ? @uploader.uploader_dir : @uploader.uploader_name
      end

      def store_name
        if @uploader.respond_to?(:uploader_name_format) 
          name_format = @uploader.uploader_name_format
          name = name_format[:name]
          if name_format[:format].to_s == "downcase" 
            name = name.downcase
          elsif name_format[:format].to_s == "upcase"
            name = name.upcase
          end
        else
          name = upload_file[:basename]
        end
        return name
      end

      def set_upload_name(size_name = nil )
        if size_name 
          store_file = store_name + "_#{size_name.to_s}" + "." + upload_file[:extension] 
        else
          store_file = store_name + "." + upload_file[:extension] 
        end
        return store_file
      end

      def connection
        options = self.class.get_option(self)
        basic = self.class.get_basic_auth(self)
        token = self.class.token_auth
        conn = Http::Client.new(options[:url]) do |builder|
          builder.headers = options[:headers]
          builder.basic_auth(basic[:user], basic[:password]) if !basic.nil?
          builder.token_auth(self, token) if !token.nil? 
        end
        return conn
      end

      class << self
        def conn_option(&block)
          return @option_proc unless block_given?
          @option_proc = block
        end

        def get_option(klass)
          klass.instance_eval(&conn_option)
        end

        def basic_auth(&block)
          return @basic_proc unless block_given?
          @basic_proc = block
        end

        def get_basic_auth(klass)
          return nil if basic_auth.nil?
          klass.instance_eval(&basic_auth)
        end

        def token_auth(&block)
          return @token_proc unless block_given?
          @token_proc = block
        end
      end
    end
  end
end
