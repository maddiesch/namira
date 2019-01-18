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
        env.response = handle_response(env)
        @app.call(env)
      end

      private

      def handle_response(env)
        final = Namira::Response.new(
          env.method,
          env.uri,
          env.redirect_count,
          env.response
        )
        if (200...300).cover?(env.response.status)
          final
        else
          raise Errors::HTTPError.create(final)
        end
      end
    end
  end
end
