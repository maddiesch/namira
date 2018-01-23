module Namira
  module Errors
    ##
    # A RedirectError
    #
    # @!attribute [r] message
    #   @return [String] Will contain information about the error.
    class RedirectError < BaseError
      ##
      # The location the redirect is pointing to
      # @return [String]
      attr_reader :location

      ##
      # The number of redirects that occured
      # @return [Integer]
      attr_reader :count

      ##
      # Creates a new instance
      def initialize(msg, location, count)
        super(msg)
        @location = location
        @count = count
      end
    end
  end
end
