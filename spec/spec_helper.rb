require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'pry'
require 'webmock/rspec'
require 'namira'

Dir.glob(File.expand_path("#{__dir__}/support/**/*.rb")).each { |f| require f }

Namira.configure do |c|
  c.log_requests = false
end

RSpec.configure do |config|
  config.before do
    stub_request(:any, /echo-api\.test/).to_rack(EchoAPI)
  end
end

