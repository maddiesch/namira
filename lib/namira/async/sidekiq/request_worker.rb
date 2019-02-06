require_relative '../performer'

module Namira
  module Async
    module Sidekiq
      class RequestWorker
        include ::Sidekiq::Worker

        def perform(payload)
          Namira::Async::Performer.perform(payload)
        end
      end
    end
  end
end
