module Namira
  ##
  # The middleware stack used to send a request
  class Stack
    class << self
      ##
      # The default middleware stack
      def default
        Stack.new do
          use Middleware::Config
          use Middleware::Header
          use Middleware::Timing
          use Middleware::Redirector
          use Middleware::Logger
          use Middleware::Timeout
          use Middleware::Network
          use Middleware::Responder
        end
      end
    end

    def initialize(&block)
      @middleware = []
      instance_eval(&block)
    end

    ##
    # Called by the middleware runner.
    #
    # @param env [Namira::Env] The request environment
    def call(env)
      raise ArgumentError, 'Invalid environment' unless env.is_a?(Namira::Env)

      to_app.call(env)
    end

    ##
    # Add a class to the middleware stack
    #
    # @param klass [Class, #call] The middleware class
    # @param args [Any] Arguments passed to the class initializer
    # @param block [Block] A block to pass to the class initializer
    def use(klass, *args, &block)
      @middleware << lambda do |app|
        klass.new(app, *args, &block)
      end
    end

    private

    def to_app
      application = ->(env) { env }
      @middleware.reverse.inject(application) do |app, component|
        component.call(app)
      end
    end
  end
end
