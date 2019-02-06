# rubocop:disable Lint/HandleExceptions
begin
  require 'active_job'
rescue LoadError; end
begin
  require 'sidekiq'
rescue LoadError; end
# rubocop:enable Lint/HandleExceptions

require_relative 'async/active_job/request_job' if defined?(::ActiveJob)
require_relative 'async/sidekiq/request_worker' if defined?(::Sidekiq)

require_relative 'async/performer'
require_relative 'async/serializer'
