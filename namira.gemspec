lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'namira/version'

Gem::Specification.new do |spec|
  spec.name          = 'namira'
  spec.version       = Namira::VERSION
  spec.authors       = ['Maddie Schipper']
  spec.email         = ['me@maddiesch.com']

  spec.summary       = 'A simple wrapper around HTTP'
  spec.description   = 'This is a simple wrapper around HTTP'
  spec.homepage      = 'https://github.com/maddiesch/namira'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'http', '>= 4.3', '< 5.0'

  spec.add_development_dependency 'bundler',   '~> 2.0'
  spec.add_development_dependency 'pry',       '~> 0.11.3'
  spec.add_development_dependency 'rake',      '~> 10.0'
  spec.add_development_dependency 'rspec',     '~> 3.2'
  spec.add_development_dependency 'simplecov', '~> 0.15'
  spec.add_development_dependency 'sinatra',   '~> 2.0.5'
  spec.add_development_dependency 'webmock',   '~> 3.3.0'
  spec.add_development_dependency 'yard',      '~> 0.9'
end
