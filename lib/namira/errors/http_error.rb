module Namira
  module Errors
    class HTTPError < Base
      attr_reader :status, :response

      def initialize(msg, status, response)
        @status = status
        @response = response
        super(msg)
      end
    end
  end
end
