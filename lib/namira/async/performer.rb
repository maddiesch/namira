require_relative 'serializer'
require_relative '../config'
require_relative '../errors'

module Namira
  module Async
    class Performer
      class << self
        def schedule(request, async_adapter, queue_name)
          async_adapter = adapter(async_adapter)
          queue_name ||= Namira.config.async_queue_name
          payload = Namira::Async::Serializer.serialize_request(request)

          case async_adapter
          when :active_job
            Namira::Async::ActiveJob::RequestJob.set(queue: queue_name).perform_later(payload)
          when :sidekiq
            Namira::Async::Sidekiq::RequestWorker.set(queue: queue_name).perform_async(payload)
          when :thread
            Thread.new { perform(payload) }
          else
            raise Namira::Errors::AsyncError, "Unknown Async Adapter #{async_adapter}"
          end
        end

        def perform(payload)
          request = Namira::Async::Serializer.unserialize_request(payload)
          request.send_request
          Namira::Async::Serializer.serialize_response(request.response)
        end

        private

        def adapter(async_adapter)
          async_adapter ||= Namira.config.async_adapter
          if async_adapter == :active_job && !defined?(ActiveJob)
            adapter(:sidekiq)
          elsif async_adapter == :sidekiq && !defined?(Sidekiq)
            adapter(:thread)
          else
            async_adapter
          end
        end
      end
    end
  end
end
