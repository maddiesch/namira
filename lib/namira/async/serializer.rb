require_relative '../errors'

module Namira
  module Async
    class Serializer
      class << self
        def serialize_request(request)
          JSON.dump(
            u: request.uri,
            m: request.http_method,
            h: request.headers.to_h,
            b: request.body,
            c: request.config.to_h
          )
        end

        def unserialize_request(payload)
          data = JSON.parse(payload)
          Namira::Request.new(
            uri: data.fetch('u'),
            http_method: data.fetch('m').to_sym,
            headers: data.fetch('h'),
            body: data.fetch('b'),
            config: data.fetch('c')
          )
        rescue KeyError => error
          raise Namira::Errors::AsyncError, error.message
        end

        def serialize_response(response)
          backing = response.instance_variable_get('@backing')
          JSON.dump(
            b: backing.to_a,
            m: response.method,
            r: response.redirect_count,
            u: response.url.to_s,
            v: backing.instance_variable_get('@version')
          )
        end

        def unserialize_response(payload)
          data = JSON.parse(payload)
          backing = HTTP::Response.new(
            status: data.fetch('b')[0],
            headers: data.fetch('b')[1],
            body: data.fetch('b')[2],
            version: data.fetch('v')
          )
          Namira::Response.new(
            data.fetch('m').to_sym,
            Addressable::URI.parse(data.fetch('u')),
            data.fetch('r').to_i,
            backing
          )
        rescue KeyError => error
          raise Namira::Errors::AsyncError, error.message
        end
      end
    end
  end
end
