module Namira
  module Middleware
    ##
    # Performs the network request
    class Network
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        timeout = env.config[:timeout] || 30.0
        http = HTTP.timeout(
          :per_operation,
          write:   timeout,
          connect: timeout,
          read:    timeout
        )
        http = http.headers(env.headers)
        env.response = http.send(env.method, env.uri, body: env.body)
        @app.call(env)
      end
    end
  end
end
