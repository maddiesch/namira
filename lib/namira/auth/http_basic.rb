module Namira
  module Auth
    ##
    # Signs a HTTP request with HTTP basic authentication
    class HTTPBasic < Base
      attr_reader :user, :pass

      ##
      # Create a new instance
      #
      # @param user [String] The username
      # @param pass [String] The password
      def initialize(user:, pass:)
        @user = user
        @pass = pass
      end

      ##
      # Signs the request
      def sign(request)
        request.basic_auth(user: user, pass: pass)
      end
    end
  end
end
