require 'json'

module Transport

  # Transport layer for json transfers.
  class JSON

    # Parser for the json response.
    class ResponseParser

      attr_reader :result

      def initialize(http_response)
        @http_response = http_response
      end

      def perform
        parse_response_body
      end

      private

      def parse_response_body
        @result = @http_response && @http_response.strip != "" ? ::JSON.parse(@http_response) : nil
      rescue ::JSON::ParserError => error
        raise ParserError, error.to_s
      end

    end

  end

end
