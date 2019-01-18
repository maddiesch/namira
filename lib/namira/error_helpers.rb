begin
  require 'bugsnag'
rescue LoadError
end

require_relative 'errors'

if defined?(::Bugsnag)
  module Namira
    module ErrorHelpers
      class Bugsnag
        def initialize(bugsnag)
          @bugsnag = bugsnag
        end

        def call(notification)
          notification.exceptions.each do |exception|
            next unless exception.is_a?(Namira::Errors::HTTPError)

            notification.add_tab("Namira #{exception.response.status.to_i}", {
              headers: exception.response.headers.to_h,
              body: exception.response.body.to_s[0...200],
              method: exception.response.method.to_s,
              url: exception.response.url.to_s,
              redirected: (exception.response.redirect_count > 0).to_s
            })
          end

          @bugsnag.call(notification)
        end
      end
    end
  end

  ::Bugsnag.configure do |config|
    config.middleware.use Namira::ErrorHelpers::Bugsnag
  end
end
