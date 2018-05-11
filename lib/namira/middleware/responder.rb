module Namira
  module Middleware
    ##
    # Builds the {Namira::Response} from the backend responses
    class Responder
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        handle_response(env.response)
        env.response = Namira::Response.new(env.response)
        @app.call(env)
      end

      private

      def handle_response(response)
        final = Namira::Response.new(response)
        if (200...300).cover?(response.status)
          final
        else
          raise Errors::HTTPError.create(final)
        end
      end
    end
  end
end
