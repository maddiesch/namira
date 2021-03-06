require 'ostruct'
require 'namira/version'

##
module Namira
  ##
  # Namira configuration
  #
  #   Namira.configure do |config|
  #     config.user_agent = "MyCoolApp"
  #   end
  #
  # @!attribute [rw] max_redirect
  #   The maximum number of redirects to follow before throwing a {Namira::Errors::RedirectError}
  #   @return [Integer] Defaults: 3
  #
  # @!attribute [rw] timeout
  #   The max length of time (in seconds) Namira will wait before canceling the request and
  #   throwing a {Namira::Errors::TimeoutError}
  #   @return [Float] Defaults: 5.0
  #
  # @!attribute [rw] backend
  #   The backend Namira will use to send the request.
  #   @return [Namira::Backend] This returns a Class and not an instance. Defaults: {Namira::Backend}
  #
  # @!attribute [rw] user_agent
  #   The string to send for the "User-Agent" header. The value set here will be overriden if a user agent is
  #   specified on the request itself.
  #   @return [String] Defaults: Namira/1.0
  #
  # @!attribute [r] headers
  #   Default headers to send with each request
  #   @return [Hash]
  #
  # @!attribute [rw] log_requests
  #   Log requests using puts or Rails.logger.debug if it's defined
  #   @return (Bool) Defaults: true
  #
  # @!attribute [rw] async_queue_name
  #   The queue name that async requests should be added too.
  #   @return [Symbol] Defaults: :default
  #
  # @!attribute [rw] async_adapter
  #   The preferred async adapter to use.
  #   Possible Values: :active_job, :sidekiq
  #   @return [Symbol] Defaults: :active_job
  class Config < OpenStruct
    ##
    # The
    # attr_accessor :max_redirect
    # attr_accessor :timeout
    # attr_accessor :backend
    # attr_accessor :user_agent

    DEFAULT_SETTINGS = {
      max_redirect: 3,
      timeout: 5.0,
      backend: nil,
      user_agent: "Namira/#{Namira::VERSION}",
      headers: {},
      log_requests: true,
      async_queue_name: :default,
      async_adapter: :active_job
    }.freeze

    private_constant :DEFAULT_SETTINGS

    def initialize
      super(DEFAULT_SETTINGS)
    end
  end

  ##
  # The shared configuration
  def self.configure
    yield(config) if block_given?
    config
  end

  def self.config
    @config ||= Config.new
    @config
  end
end
