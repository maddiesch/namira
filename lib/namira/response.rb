module Namira
  class Response
    def initialize(backing)
      @backing = backing
    end

    def from_json
      @json ||= JSON.parse(@backing.body)
    end

    def method_missing(name, *args)
      if @backing.respond_to?(name)
        @backing.send(name, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @bakcing.respond_to?(method_name) || super
    end
  end
end
