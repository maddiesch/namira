module Namira
  module Errors
    class HTTPError < Base
      attr_reader :status

      def initialize(msg, status)
        @status = status
        super(msg)
      end
    end
  end
end
