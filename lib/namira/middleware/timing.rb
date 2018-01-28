module Namira
  module Middleware
    ##
    # Records timing for the request
    class Timing
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        start_time = Time.now
        result = @app.call(env)
        result.timing = Time.now - start_time
        result
      end
    end
  end
end
