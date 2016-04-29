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
  end
end
