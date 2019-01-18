module Namira
  ##
  # HTTP response
  class Response
    attr_reader :method

    attr_reader :url

    attr_reader :redirect_count

    ##
    # Create a new {Namira::Response}
    def initialize(method, url, redirect_count, backing)
      @method = method
      @url = url
      @redirect_count = redirect_count
      @backing = backing
    end

    ##
    # @return [Hash, Array] Parse the response body as JSON
    def from_json
      @from_json ||= JSON.parse(@backing.body)
    end

    ##
    # @return [String] Returns the response as a string
    def to_s
      @backing.to_s
    end

    ##
    # @return [Bool] If the response status 2xx
    def ok?
      (200...300).cover?(@backing.status)
    end

    ##
    # Proxies methods to the backing object
    def method_missing(name, *args)
      if @backing.respond_to?(name)
        @backing.send(name, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @backing.respond_to?(method_name) || super
    end
  end
end
