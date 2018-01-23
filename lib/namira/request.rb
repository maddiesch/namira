require 'http'

module Namira
  ##
  # The request class is used to create and send HTTP requests.
  #
  #   response = Namira::Request.new(uri: 'https://httpbin.org/headers').response
  class Request
    attr_reader :uri, :http_method

    ##
    # Create a new request
    #
    # @param uri [String] The request URL
    # @param http_method [Symbol] The HTTP method for the request. (Default `:get`)
    # @param headers [Hash] Additional headers to send with the request. (Default: `{}`)
    # @param body [String, #to_s] The body to send. (Default: nil)
    # @param auth [Namira::Auth::Base] The auth instance used to sign requests.
    # @param config [Hash] {Namira::Config} overrides
    def initialize(uri:, http_method: :get, headers: {}, body: nil, auth: nil, config: {})
      @uri          = uri
      @http_method  = http_method
      @headers      = Hash(headers)
      @body         = body
      @auth         = auth
      @timeout      = config[:timeout] || Namira.configure.timeout
      @max_redirect = config[:max_redirect] || Namira.configure.max_redirect
      @backend      = config[:backend] || Namira.configure.backend || Namira::Backend
      @user_agent   = config[:user_agent] || Namira.configure.user_agent
      @max_redirect = Backend::NO_FOLLOW_REDIRECT_COUNT if config[:follow_redirect] == false
    end

    ##
    # Sends the request.
    #
    # Every time this method is called a network request will be sent.
    def send_request
      @response = _send_request(uri)
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

    def build_headers
      {}.tap do |headers|
        headers['User-Agent'] = @user_agent
        Namira.configure.headers.to_h.each do |k, v|
          key = k.to_s.split('_').map(&:capitalize).join('-')
          headers[key] = v
        end
        @headers.each do |k, v|
          headers[k] = v
        end
      end
    end

    def _send_request(uri)
      @backend.send_request(
        uri:          uri,
        method:       http_method,
        headers:      build_headers,
        max_redirect: @max_redirect,
        timeout:      @timeout,
        body:         @body,
        auth:         @auth
      )
    end
  end
end
