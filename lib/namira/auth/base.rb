module Namira
  ##
  # Authentication
  module Auth
    ##
    # The base authentication class
    class Base
      attr_accessor :sign_redirects

      def sign_redirects?
        if @sign_redirects.nil?
          true
        else
          @sign_redirects == true
        end
      end

      ##
      # @private
      #
      # Signs a request.
      #
      # @param backend [HTTP] The request being signed
      # @param redirect_count [Integer] The number of redirects this request has encountered
      def sign_request(backend, redirect_count)
        return if redirect_count > 0 && !sign_redirects?
        sign(backend)
      end

      ##
      # Perform the signing of the request
      #
      # @param backend [HTTP] The instance of the backend request to sign.
      def sign(_backend)
        raise NotImplementedError, 'Auth should override the `sign` method'
      end
    end
  end
end
