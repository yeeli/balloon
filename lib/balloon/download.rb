require 'faraday'
require 'mime/types'

module Balloon
  module Download
    extend ActiveSupport::Concern

    def down_url(uri)
      connection = ::Faraday.new({:ssl => {:verify => false}})
      response = connection.get(uri)
      generate_down_cache_directory
      path = File.join down_cache_path, generate_down_id

      if response.status != 200
        raise Balloon::DownloadError, I18n.translate(:"errors.messages.response_error")
      end

      if content_type = MIME::Types[response.headers["content-type"]][0]
        mime_type = content_type.content_type
        if self.respond_to?(:uploader_mimetype_white)
           if !uploader_mimetype_white.include?(mime_type)
             raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
           end
        elsif self.respond_to?(:uploader_mimetype_black)
           if !uploader_mimetype_black.include?(mime_type)
             raise Balloon::DownloadError, I18n.translate(:"errors.messages.down_mime_error")
           end
        end
      end

      File.open(path, "wb") do |f|
        f.write(response.body)
      end

      return path
    rescue Faraday::ConnectionFailed => e
      raise Balloon::DownloadError, I18n.translate(:"errors.messages.connection_failed")
    rescue Faraday::TimeoutError => e
      raise Ballloon::DownloadError, I18n.translate(:"errors.messages.timeout_error")
    end

    private

    def generate_down_id
      now = Time.now
      "#{now.to_i}#{now.usec.to_s[0, 5]}".to_i.to_s(16)
    end
  end
end

