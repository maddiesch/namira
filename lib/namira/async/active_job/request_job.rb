require_relative '../performer'

module Namira
  module Async
    module ActiveJob
      class RequestJob < ::ActiveJob::Base
        def perform(payload)
          Namira::Async::Performer.perform(payload)
        end
      end
    end
  end
end
