module Namira
  module Errors
    ##
    # HTTP Error
    #
    # Any non 2xx status code will raise this error.
    class HTTPError < BaseError
      ##
      # @return [Integer] The HTTP status that caused the error
      attr_reader :status

      ##
      # @return [Namira::Response] The HTTP response
      attr_reader :response

      ##
      # Returns a new instance of HTTPError
      #
      # @param msg [String] The error message. e.g. "http_error/500"
      # @param status [Integer] The HTTP status that caused the error
      # @param response [Namira::Response] The HTTP response
      def initialize(msg, status, response)
        @status = status
        @response = response
        super(msg)
      end
    end
  end
end
