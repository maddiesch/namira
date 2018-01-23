require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'webmock/rspec'
require 'namira'

Namira.configure do |c|
  c.log_requests = false
end
