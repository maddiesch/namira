module Namira
  class Backend

    #
    # This allows anyone to substitute in their own networking stack.
    #
    # Any class that implements this method and resturns a `Namira::Response` object can be a fully qualified backend
    #
    # The required params are
    #
    #  uri:          The URI to fetch
    #  method:       The HTTP method to use, expressed as a Symbol i.e. `:get`
    #  headers:      The full HTTP headers to send from the request expressed as a Hash
    #  max_redirect: The maximum number of redirects to follow.  Passed from the Request
    #  timeout:      The number of seconds before a timeout should occure
    #
    # This class is 100% capable of fufilling all Namira's needs.  But this is an option if you really need to provide a custom networking backend
    #
    def self.send_request(uri:, method:, headers:, max_redirect:, timeout:, body:)
      Backend.new.send_request(uri, method, headers, max_redirect, timeout, body)
    end

    def send_request(uri, method, headers, max_redirect, timeout, body)
      @redirect_count ||= 0
      fail Errors::TooManyRedirects, "Max number of redirects #{@redirect_count} for #{uri}" if @redirect_count > max_redirect

      if defined?(::Rails)
        Rails.logger.debug "#{method.to_s.upcase} - #{uri}"
      else
        puts "#{method.to_s.upcase} - #{uri}"
      end

      http = HTTP.timeout(
          :per_operation,
          write:   timeout,
          connect: timeout,
          read:    timeout
        )
        .headers(headers)

      response = http.send(method, uri, body: body)

      case response.status
      when 200..299
        Namira::Response.new(response)
      when 301, 302
        @redirect_count += 1
        location = response.headers['Location']
        fail Errors::RedirectError, "Request redirected but no location was supplied" if location.nil?
        send_request(location, method, headers, max_redirect, timeout, body)
      else
        fail Errors::HTTPError.new("http_error/#{response.status}", response.status)
      end

    rescue HTTP::TimeoutError => e
      fail Namira::Errors::Timeout.new(e.message)
    end
  end
end
