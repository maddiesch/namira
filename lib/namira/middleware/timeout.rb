module Namira
  module Middleware
    ##
    # Handles timeout errors
    class Timeout
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        @app.call(env)
      rescue HTTP::TimeoutError => e
        raise Errors::TimeoutError.new(e.message)
      end
    end
  end
end
