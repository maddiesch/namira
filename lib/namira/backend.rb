module Namira
  ##
  # The backend is responsible for sending the requests.
  #
  # Namira uses HTTP Gem as its default backend. You can create your own backend and override `.send_request` to
  # use a different network stack.
  #
  #   Namira.config do |c|
  #     c.backend = CustomBackend
  #   end
  #
  # A fully compatable backend should handle redirects, respecting the max_redirect parameter as well as
  # throwing a Errors::HTTPError for anything but a redirect & 2xx status code.
  class Backend
    ##
    # This allows anyone to substitute in their own networking stack.
    #
    # Any class that implements this method and resturns a `Namira::Response` object can be a fully qualified backend.
    #
    # @param uri [String] The URI to fetch
    # @param method [Symbol] The HTTP method to use, expressed as a Symbol i.e. `:get`
    # @param headers [Hash] The full HTTP headers to send from the request expressed as a Hash
    # @param max_redirect [Integer] The maximum number of redirects to follow.  Passed from the Request
    # @param timeout [Integer] The number of seconds before a timeout should occure
    # @param auth [Namira::Auth::Base] The `Namira::Auth::Base` subclass instance or nil to sign the request with
    #
    # @return [Namira::Response] The HTTP response
    def self.send_request(uri:, method:, headers:, max_redirect:, timeout:, body:, auth:)
      Backend.new(
        uri: uri,
        method: method,
        headers: headers,
        max_redirect: max_redirect,
        timeout: timeout,
        body: body,
        auth: auth
      ).execute
    end

    ##
    # The default max redirects to consider the request a "no follow"
    NO_FOLLOW_REDIRECT_COUNT = -1

    ##
    # @private
    def initialize(opts = {})
      opts.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      @redirect_count = 0
    end

    ##
    # @private
    #
    # Perform the request
    def execute(location = nil)
      ensure_redirect_count!(location)
      prepare_request
      sign_request_if_needed
      send_request(location || @uri)
      handle_response
    end

    private

    def ensure_redirect_count!(location)
      return if @redirect_count.zero?
      return if @redirect_count <= @max_redirect
      raise Errors::RedirectError.new(
        "Max number of redirects #{@redirect_count} for #{@uri}",
        location,
        @redirect_count
      )
    end

    def prepare_request
      @http = HTTP.timeout(
        :per_operation,
        write:   @timeout,
        connect: @timeout,
        read:    @timeout
      ).headers(@headers)
    end

    def log_request(method, uri)
      return unless Namira.configure.log_requests
      if defined?(::Rails)
        Rails.logger.debug "#{method.to_s.upcase} - #{uri}"
      else
        STDOUT.puts "#{method.to_s.upcase} - #{uri}"
      end
    end

    def send_request(location)
      log_request(@method, location)
      @response = @http.send(@method, location, body: @body)
    rescue HTTP::TimeoutError => e
      raise Namira::Errors::TimeoutError.new(e.message)
    rescue Addressable::URI::InvalidURIError => e
      raise Namira::Errors::InvalidURIError.new(e.message)
    end

    def sign_request_if_needed
      @http = @auth.sign_request(@http, @redirect_count) unless @auth.nil?
    end

    def handle_response
      case @response.status
      when 200..299
        create_response
      when 301, 302
        handle_redirect
      else
        create_error_response
      end
    end

    def create_response
      Namira::Response.new(@response)
    end

    def create_error_response
      raise Errors::HTTPError.new("http_error/#{@response.status}", @response.status, create_response)
    end

    def handle_redirect
      if @max_redirect == NO_FOLLOW_REDIRECT_COUNT
        create_error_response
      else
        @redirect_count += 1
        location = @response.headers['Location']
        raise Errors::RedirectError.new('Request redirected but no location was supplied', nil, @redirect_count) if location.nil?
        execute(location)
      end
    end
  end
end
