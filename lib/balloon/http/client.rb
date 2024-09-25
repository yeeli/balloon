require 'faraday'

module Balloon
  module Http
    class Client

      attr_reader :url
      
      attr_reader :login, :pass
      
      attr_reader :klass, :token

      attr_accessor :headers

      attr_accessor :options

      attr_accessor :connection

      attr_accessor :conn_build

      def initialize(uri = nil, options = nil, &block)
        @url = uri
        yield self if block_given?
      end

      def builder(&block)
        @conn_build = block
      end

      def url=(uri)
        @conn = nil
        @url = uri
      end

      def basic_auth(login, pass)
        @login = login
        @pass = pass
      end

      def token_auth(klass, token)
        @klass = klass
        @token = token
      end

      def connection
        @connection ||= begin
                          conn = Faraday.new(url: url)
                          conn.request(:authorization, :basic, login, pass) if login
                          conn.build do |b|
                            conn_build.call(b)
                          end if conn_build
                          conn
                        end
      end

      def request(verb, uri, query={}, size = nil)
        headers['Authorization'] = klass.instance_eval(token.call(verb.to_s.upcase, uri, size, headers['Date'])) if token
        verb == :get ? query_get = query : query_post = query
        uri = connection.build_url(uri, query_get)
        response = connection.run_request(verb, uri, query_post, headers) do |request|
          yield request if block_given?
        end
        response = Response.new(response)
        case response.status
        when 301, 302, 303, 307
          request(verb, response.headers['location'], query)
        when 200..299, 300..399
          response
        end
      end

      def get(uri, query = {}, &block) 
        request(:get, uri, query, 0, &block)
      end

      def post(uri, query = {}, size = nil, &block)
        size = size || 0
        request(:post, uri, query, size,&block)
      end

      def put(uri, query  = {}, size = nil, &block)
        size = size || 0
        request(:put, uri, query, size, &block)
      end

      def delete(uri, &block)
        request(:delete, uri, nil, 0, &block)
      end
    end
  end
end
