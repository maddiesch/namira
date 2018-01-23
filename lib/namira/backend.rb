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
      Backend.new.send_request(uri, method, headers, max_redirect, timeout, body, auth)
    end

    ##
    # @private
    #
    # The default backend
    def send_request(uri, method, headers, max_redirect, timeout, body, auth)
      @redirect_count ||= 0
      raise Errors::RedirectError, "Max number of redirects #{@redirect_count} for #{uri}" if @redirect_count > max_redirect

      log_request(method, uri)

      http = HTTP.timeout(
        :per_operation,
        write:   timeout,
        connect: timeout,
        read:    timeout
      ).headers(headers)

      http = auth.sign_request(http, @redirect_count) unless auth.nil?

      response = http.send(method, uri, body: body)

      case response.status
      when 200..299
        Namira::Response.new(response)
      when 301, 302
        @redirect_count += 1
        location = response.headers['Location']
        raise Errors::RedirectError, 'Request redirected but no location was supplied' if location.nil?
        send_request(location, method, headers, max_redirect, timeout, body, auth)
      else
        raise Errors::HTTPError.new("http_error/#{response.status}", response.status, Namira::Response.new(response))
      end
    rescue HTTP::TimeoutError => e
      raise Namira::Errors::TimeoutError.new(e.message)
    rescue Addressable::URI::InvalidURIError => e
      raise Namira::Errors::InvalidURIError.new(e.message)
    end

    private

    def log_request(method, uri)
      return unless Namira.configure.log_requests
      if defined?(::Rails)
        Rails.logger.debug "#{method.to_s.upcase} - #{uri}"
      else
        STDOUT.puts "#{method.to_s.upcase} - #{uri}"
      end
    end
  end
end
