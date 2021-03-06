module Balloon
  module Http
    class Response
      attr_reader :response

      CONTENT_TYPE = {
        'application/json' => :json,
        'application/x-www-form-urlencoded' => :html,
        'text/html' => :html,
        'text/javascript' => :json
      }

      PARSERS = {
        :json => lambda{ |body| MultiJson.respond_to?(:adapter) ? MultiJson.load(body) : MultiJson.decode(body) rescue body},
        :html => lambda{ |body| Nokogiri::HTML(body)}
      }

      def initialize(response)
        @response = response
      end

      def headers
        response.headers
      end

      def body
        decode(response.body)
      end

      def decode(body)
        return '' if !body 
        return body if json?
        charset = body.match(/charset\s*=[\s|\W]*([\w-]+)/)
        if charset[1].downcase != "utf-8"
          begin
            body.encode! "utf-8", charset[1], {:invalid => :replace} 
          rescue
            body
          end
        else
          body
        end
      end

      def status
        response.status
      end

      # Attempts to determine the content type of the response.
      def content_type
        ((response.headers.values_at('content-type', 'Content-Type').compact.first || '').split(';').first || '').strip
      end

      def json?
        CONTENT_TYPE[content_type] == :json || !response.body.match(/\<html/)
      end

      def parser
        type = CONTENT_TYPE[content_type]
        type = :json if type == :html && !response.body.match(/\<html/) 
        return type
      end

      def parsed
        return nil unless CONTENT_TYPE.key?(content_type)
        return nil unless PARSERS.key?(parser)
        @parsed ||= PARSERS[parser].call(body)
      end
    end
  end
end
