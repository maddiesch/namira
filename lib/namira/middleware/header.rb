module Namira
  module Middleware
    ##
    # Creates the final request headers by merging global, defaults, and request headers
    class Header
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        headers = Hash(Namira.config.headers.to_h).dup
        headers.merge!(additional_headers(env))
        headers.merge!(env.headers.to_h)
        env.headers = convert_headers(headers)
        @app.call(env)
      end

      private

      def additional_headers(env)
        {
          'User-Agent' => env.config[:user_agent]
        }
      end

      def convert_headers(headers)
        headers.each_with_object({}) do |(key, value), obj|
          header = key.to_s.split(/-|_/).map(&:capitalize).join('-')
          obj[header] = value
        end
      end
    end
  end
end
