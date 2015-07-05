module Balloon
  module Configuration

    STORAGE_EGINE = { file: "Balloon::Storage::File", upyun: "Balloon::Storage::Upyun" }

    class << self
      def included(base)
        base.extend ClassMethods
        set_config :root
        set_config :permissions
        set_config :dir_permissions
        set_config :store_storage
        set_config :cache_dir
        set_config :store_dir
        set_config :assert_host

        set_config :upyun_api_host
        set_config :upyun_username
        set_config :upyun_password
        set_config :upyun_bucket
        set_config :upyun_timeout
        set_config :upyun_domain
        set_config :upyun_thumb_symbol
        set_config :upyun_is_image
        set_config :upyun_headers

        reset_config if base == Balloon::Base
      end

      def set_config(name)
        ClassMethods.class_eval <<-RUBY
          attr_writer :#{name}
          alias :uploader_#{name} :#{name}=
          def #{name}; @#{name}; end
        RUBY

        class_eval <<-RUBY
          def #{name}
            value = self.class.#{name}
            value.nil? ? Balloon::Base.#{name} : value
          end
        RUBY
      end

      def reset_config
        Balloon.configure do |config|
          config.root = Balloon.root 
          config.permissions = 0644
          config.dir_permissions = 0755
          config.store_storage = :file
          config.store_dir = "public"
          config.cache_dir = "tmp"

          config.upyun_headers = {}
          config.upyun_thumb_symbol = '!'
          config.upyun_is_image = false
        end
      end
    end

    module ClassMethods
      def configure; yield self; end

      def setup(configure, env)
        conf = configure[env]
        conf = configure['defaults'] if conf.nil?
        Balloon.configure do |config|
          conf.each do | n, v |
            if !v.blank? || v ==true || v == false
              if v ==true || v == false
                class_eval <<-RUBY
                  config.#{n} = #{v}
                  RUBY
              else
                class_eval <<-RUBY
                  config.#{n} = '#{v}'
                RUBY
              end
            end
          end
        end
      end
    end
  end
end
