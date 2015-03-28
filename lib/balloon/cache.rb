module Balloon
  module Cache
    extend ActiveSupport::Concern

    attr_reader :cache_cid

    # generate cache directory in system
    #
    # @return 
    def generate_cache_directory
      @cache_cid = generate_cid
      FileUtils.mkdir_p(cache_path)
      FileUtils.chmod dir_permissions.to_i, cache_path
    end

    def cache_path
      File.expand_path cache_directory, root
    end

    def cache_directory
      File.join cache_dir, "images", cache_cid
    end

    def generate_down_cache_directory
      FileUtils.mkdir_p(down_cache_path)
      FileUtils.chmod dir_permissions.to_i, down_cache_path
    end

    def down_cache_path
      File.expand_path down_cache_directory, root
    end

    def down_cache_directory
      File.join cache_dir, "net"
    end

    private

    def generate_cid
      now = Time.now
      "#{now.to_i}.#{now.usec}.#{Process.pid}"      
    end
  end
end
