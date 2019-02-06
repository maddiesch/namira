module Namira
  module Middleware
    ##
    # Duplicates the global config for modification by other middleware
    class Config
      def initialize(app)
        @app = app
      end

      ##
      # Called by the middleware runner.
      #
      # @param env [Namira::Env] The request environment
      def call(env)
        env.config = merge_config(env.config.dup)
        @app.call(env)
      end

      private

      def merge_config(config)
        Namira.config.to_h.merge(config)
      end
    end
  end
end
