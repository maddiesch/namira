require 'http'

module Namira
  class Request
    attr_reader :uri, :http_method

    def initialize(uri:, http_method: :get, headers: {}, body: nil, auth: nil, config: {})
      @uri          = uri
      @http_method  = http_method
      @headers      = headers || {}
      @body         = body
      @auth         = auth
      @timeout      = config[:timeout] || Namira.configure.timeout
      @max_redirect = config[:max_redirect] || Namira.configure.max_redirect
      @backend      = config[:backend] || Namira.configure.backend || Namira::Backend
      @user_agent   = config[:user_agent] || Namira.configure.user_agent
    end

    def send_request
      @response ||= _send_request(uri)
    end

    def response
      send_request
    end

    private

    def build_headers
      {}.tap do |headers|
        headers['User-Agent'] = @user_agent
        Namira.configure.headers.each do |k, v|
          key = k.split('_').map(&:capitalize).join('-')
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
