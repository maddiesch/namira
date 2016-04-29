module Namira
  class QueryBuilder
    def initialize
      @backing = {}
    end

    def method_missing(name, *args)
      if name.to_s =~ /=$/
        @backing[name.to_s.gsub(/=$/, '')] = args.first
      else
        @backing[name.to_s]
      end
    end

    def to_s
      @backing.map { |k, v| "#{k}=#{v}" }.join('&')
    end
  end
end
