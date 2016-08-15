require 'namira/version'
require 'namira/request'
require 'namira/response'
require 'namira/errors'
require 'namira/config'
require 'namira/query_builder'
require 'namira/backend'
require 'namira/extensions/hash_key_path'
require 'namira/auth'

Hash.include(Namira::Extensions::HashKeyPath)
