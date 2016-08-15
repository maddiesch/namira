module Namira
  class Config
    attr_accessor :max_redirect, :timeout, :backend, :user_agent

    DEFAULT_SETTINGS = {
      max_redirect: 3,
      timeout:      5.0,
      backend:      nil,
      user_agent:   "Namira/#{Namira::VERSION}"
    }.freeze

    def initialize
      DEFAULT_SETTINGS.each do |k, v|
        send("#{k}=", v)
      end
    end

    def headers
      @headers ||= OpenStruct.new
    end
  end

  def self.configure
    @config ||= Config.new
    yield(@config) if block_given?
    @config
  end
end
