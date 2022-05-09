module Balloon
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      desc "create the Balloon configuration at config/balloon.yml"

      def self.source_root
        @source_root ||= File.expand_path("../templates", __FILE__)
      end

      def create_config_file
        template 'balloon.yml', File.join('config', 'balloon.yml')
      end
    end
  end
end
