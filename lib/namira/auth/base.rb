module Namira
  module Auth
    class Base
      attr_accessor :sign_redirects

      def sign_redirects?
        if @sign_redirects.nil?
          true
        else
          @sign_redirects == true
        end
      end

      def sign_request(backend, redirect_count)
        return if redirect_count > 0 && !sign_redirects?
        sign(backend)
      end

      def sign(_backend)
        raise NotImplementedError, 'Auth should override the `sign` method'
      end
    end
  end
end
