module Namira
  module Auth
    class HTTPBasic < Base
      attr_reader :user, :pass

      def initialize(user:, pass:)
        @user = user
        @pass = pass
      end

      def sign(request)
        request.basic_auth(user: user, pass: pass)
      end
    end
  end
end
