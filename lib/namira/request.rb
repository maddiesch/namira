require 'http'
require_relative 'async'

module Namira
  ##
  # The request class is used to create and send HTTP requests.
  #
  #   response = Namira::Request.new(uri: 'https://httpbin.org/headers').response
  class Request
    attr_reader :uri, :http_method, :headers, :body, :config

    ##
    # Create a new request
    #
    # @param uri [String] The request URL
    # @param http_method [Symbol] The HTTP method for the request. (Default `:get`)
    # @param headers [Hash] Additional headers to send with the request. (Default: `{}`)
    # @param body [String, #to_s] The body to send. (Default: nil)
    # @param config [Hash] {Namira::Config} overrides
    def initialize(uri:, http_method: :get, headers: {}, body: nil, config: {})
      @uri         = uri
      @http_method = http_method
      @headers     = Hash(headers)
      @body        = body
      @config      = Namira.config.to_h.merge(Hash(config))
      @stack       = Namira::Stack.default
    end

    ##
    # Sends the request.
    #
    # Every time this method is called a network request will be sent.
    def send_request
      @response = _send_request
    end

    def send_async(queue_name: nil, adapter: nil)
      Namira::Async::Performer.schedule(self, adapter, queue_name)
    end

    ##
    # The {Namira::Response} for the request.
    #
    # If the request hasn't been sent yet calling this will get the request.
    #
    # @return {Namira::Response}
    def response
      send_request if @response.nil?
      @response
    end

    private

    def env
      Namira::Env.new(
        uri: @uri,
        method: @http_method,
        body: @body,
        headers: @headers,
        config: @config
      )
    end

    def _send_request
      @stack.call(env).response
    rescue Addressable::URI::InvalidURIError => e
      raise Namira::Errors::InvalidURIError.new(e.message)
    end
  end
end
