require 'balloon/version'
require 'active_support'
require 'active_support/core_ext'
require 'action_dispatch'

# Balloon
module Balloon
  class << self
    attr_accessor :root
    def configure(&block)
      Balloon::Base.configure &block
    end

    def configure_load(config, env)
      Balloon::Base.setup config, env
    end
  end

  autoload :Uploader, 'balloon/uploader'
  autoload :Base, 'balloon/base'
  autoload :Configuration, 'balloon/configuration'
  autoload :Processing, 'balloon/processing'
  autoload :Cache, 'balloon/cache'
  autoload :FileExtension, 'balloon/file_extension'
  autoload :Download, 'balloon/download'
  autoload :Validate, 'balloon/validate'

  module Http
    autoload :Client, 'balloon/http/client'
    autoload :Response, 'balloon/http/response'
  end

  module Storage
    autoload :Store, 'balloon/storage/store'
    autoload :File, 'balloon/storage/file'
    autoload :Upyun, 'balloon/storage/upyun'
  end

  autoload :Up, 'balloon/up'
end

require 'balloon/load'
require 'balloon/error'
