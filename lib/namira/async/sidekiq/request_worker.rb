require_relative '../performer'

module Namira
  module Async
    module ActiveJob
      class RequestWorker
        include Sidekiq::Worker

        def perform(payload)
          Namira::Async::Performer.perform(payload)
        end
      end
    end
  end
end
