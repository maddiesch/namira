module Namira
  class Config
    attr_accessor :max_redirect, :timeout, :backend, :user_agent

    DEFAULT_SETTINGS = {
      max_redirect: 3,
      timeout:      5.0,
      backend:      nil,
      user_agent:   "Namira/#{Namira::VERSION}"
    }

    def initialize
      DEFAULT_SETTINGS.each do |k, v|
        self.send("#{k}=", v)
      end
    end

    def headers
      @headers ||= ConfigHash.new
    end
  end

  class ConfigHash < Hash
    def method_missing(name, *args)
      if name.to_s =~ /=$/
        self[name.to_s.gsub(/=$/, '')] = args.first
      else
        self[name]
      end
    end
  end

  def self.configure
    @config ||= Config.new
    yield(@config) if block_given?
    @config
  end
end
