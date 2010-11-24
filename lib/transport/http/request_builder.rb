require 'uri'
require 'net/http'

module Transport

  class HTTP

    # Builder for the transport layer requests
    class RequestBuilder
      include Common::RequestBuilder

      HTTP_METHODS_WITH_PARAMETERS = [ :get, :delete ].freeze unless defined?(HTTP_METHODS_WITH_PARAMETERS)
      HTTP_METHODS_WITH_BODY       = [ :post, :put ].freeze unless defined?(HTTP_METHODS_WITH_BODY)

      attr_reader :request

      def perform
        initialize_request_class
        initialize_request_path
        initialize_request
        initialize_request_authentication
        initialize_request_body
      end

      private

      def initialize_request_class
        request_class_name = @http_method.to_s.capitalize
        raise NotImplementedError, "the request method #{@http_method} is not implemented" unless Net::HTTP.const_defined?(request_class_name)
        @request_class = Net::HTTP.const_get request_class_name
      end

      def initialize_request_path
        uri = URI.parse @url
        @request_path = uri.path
        @request_path += "?" + query if HTTP_METHODS_WITH_PARAMETERS.include?(@http_method.to_sym)
      end

      def initialize_request
        @request = @request_class.new @request_path, @options[:headers]
      end

      def initialize_request_authentication
        auth_type = @options[:auth_type]
        return unless auth_type
        send :"initialize_request_#{auth_type}_authentication"
      rescue NoMethodError
        raise NotImplementedError, "the given auth_type [#{auth_type}] is not implemented"
      end

      def initialize_request_basic_authentication
        @request.basic_auth @options[:username], @options[:password]
      end

      def initialize_request_body
        @request.body = (@options.has_key?(:body) ? @options[:body] : query) if HTTP_METHODS_WITH_BODY.include?(@http_method.to_sym)
      end

      def query
        @query ||= begin
          serializer = ParameterSerializer.new @options[:parameters]
          serializer.perform
          serializer.result
        end
      end

    end

  end

end