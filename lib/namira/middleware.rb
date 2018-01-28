require_relative 'middleware/config'
require_relative 'middleware/header'
require_relative 'middleware/logger'
require_relative 'middleware/network'
require_relative 'middleware/redirector'
require_relative 'middleware/responder'
require_relative 'middleware/timeout'
require_relative 'middleware/timing'

module Namira
  ##
  # Contains the middleware classes for the default stack
  module Middleware
  end
end
