# Namira

[![Gem Version](https://badge.fury.io/rb/namira.svg)](https://badge.fury.io/rb/namira)
[![CircleCI](https://circleci.com/gh/skylarsch/namira/tree/master.svg?style=svg)](https://circleci.com/gh/skylarsch/namira/tree/master)
[![Maintainability](https://api.codeclimate.com/v1/badges/888de458aae02d3c7cfc/maintainability)](https://codeclimate.com/github/skylarsch/namira/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/888de458aae02d3c7cfc/test_coverage)](https://codeclimate.com/github/skylarsch/namira/test_coverage)

A Ruby HTTP client.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'namira'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install namira

## Documentation

Run `bundle exec yard`

## Usage

### GET

```ruby
# Create a request
request = Namira::Request.new(uri: 'https://httpbin.org/headers')

# Send the request
response = request.response

# Parse a JSON response
response.from_json
```

### POST

```ruby
# Create a request
request = Namira::Request.new(
  uri: 'https://httpbin.org/headers',
  http_method: :post,
  body: JSON.dump({})
)

# Send the request
response = request.response

# Parse a JSON response
response.from_json
```

#### Configuration

There are a few settings you can pass.

```ruby
Namira.configure do |config|
  # Total number of times to follow a redirect
  config.max_redirect = 3

  # How long each portion of a request should wait before timeout
  config.timeout      = 5.0

  # A non-default User-Agent
  config.user_agent   = 'my_app_user_agent'

  # Any additional HTTP headers for a request.  If headers are passed to the request itself they will override these settings
  config.headers.accept       = 'application/json' # Will become Accept
  config.headers.content_type = 'application/json' # Will become Content-Type
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skylarsch/namira.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
