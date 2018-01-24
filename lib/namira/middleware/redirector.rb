module Namira
  module Middleware
    ##
    # Performs following the redirect and handling multiple redirect errors.
    class Redirector
      ##
      # The HTTP status codes Namira will consider a redirect
      REDIRECT_STATUS = [301, 302].freeze

      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        @app.call(env)
      rescue Errors::HTTPError => e
        if redirect?(e, env)
          handle_redirect(env, e)
        else
          raise e
        end
      end

      private

      def handle_redirect(env, e)
        count = env.redirect_count
        redirect_count_error(env) if count >= max_redirect(env)
        location = e.response.headers['Location']
        redirect_location_error(env) if location.nil?
        env.uri = Addressable::URI.parse(location)
        env.redirect_count += 1
        call(env)
      end

      def max_redirect(env)
        env.config[:max_redirect] || 3
      end

      def redirect_count_error(env)
        raise Errors::RedirectError.new(
          "Max number of redirects #{env.redirect_count} for #{env.uri}",
          env.uri.to_s,
          env.redirect_count
        )
      end

      def redirect_location_error(env)
        raise Errors::RedirectError.new(
          'Request redirected but no location was supplied',
          nil,
          env.redirect_count
        )
      end

      def redirect?(e, env)
        return false unless env.config[:follow_redirect].nil? ? true : env.config[:follow_redirect]
        REDIRECT_STATUS.include?(e.status)
      end
    end
  end
end
