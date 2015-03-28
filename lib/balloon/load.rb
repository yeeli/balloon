if defined?(Rails)
  module Balloon
    class Railtie < Rails::Railtie
      initializer "balloon set path" do
        Balloon.root = Rails.root.to_s
      end

      initializer "Baloon.configure_rails_initializeation" do
        config_file = Rails.root.join('config/balloon.yml')
        if config_file.file?
          config = YAML.load(ERB.new(config_file.read).result)
          Balloon.configure_load(config, Rails.env)
        end
      end
    end
  end
elsif defined?(Sinatra)
  if defined?(Padrino) && defined?(PADRINO_ROOT)
    root = PADRINO_ROOT
    env = Padrino.env
  else
    root = Sinatra::Application.root
    env = Sinatra::Application.environment
  end
  Balloon.root = root
  config_file = File.join(root, 'config/balloon.yml')
  if File.exist?(config_file)
    config = YAML.load(ERB.new(File.read(config_file)).result)
    Balloon.configure_load(config, env)
  end
end

I18n.load_path << File.join(File.dirname(__FILE__), "locale", 'en.yml')
