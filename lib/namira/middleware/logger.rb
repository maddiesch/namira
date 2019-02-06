module Namira
  module Middleware
    ##
    # Performs request logging
    class Logger
      ##
      # The key that will disable logging
      SKIP_LOGGING_KEY = :skip_logging

      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        log_request(env)
        @app.call(env)
      end

      private

      def logging?(env)
        if env.config.key?(SKIP_LOGGING_KEY)
          env.config[SKIP_LOGGING_KEY] == false
        else
          Namira.config.log_requests == true
        end
      end

      def log_request(env)
        return unless logging?(env)

        message = "#{env.method.to_s.upcase} - #{env.uri}"
        if defined?(::Rails)
          Rails.logger.debug(message)
        else
          STDOUT.puts(message)
        end
      end
    end
  end
end
