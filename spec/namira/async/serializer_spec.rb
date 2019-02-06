require 'spec_helper'

describe Namira::Async::Serializer do
  describe '.serialize_request' do
    subject do
      Namira::Request.new(
        uri: 'https://www.google.com',
        headers: {
          'Content-Type' => 'application/json'
        },
        http_method: :post,
        body: JSON.dump(foo: :bar)
      )
    end

    it { expect { Namira::Async::Serializer.serialize_request(subject) }.to_not raise_error }

    it { expect(Namira::Async::Serializer.serialize_request(subject)).to_not be_nil }

    # it { puts JSON.pretty_generate(JSON.parse(Namira::Async::Serializer.serialize_request(subject))) }
  end

  describe '.unserialize_request' do
    context 'given a valid request' do
      subject do
        <<~EOF
          {
            "u": "https://www.google.com",
            "m": "post",
            "h": {
              "Content-Type": "application/json"
            },
            "b": "{\\"foo\\":\\"bar\\"}",
            "c": {
              "max_redirect": 3,
              "timeout": 5.0,
              "backend": null,
              "user_agent": "Namira/1.3.0",
              "headers": {
              },
              "log_requests": false,
              "async_queue_name": "default",
              "async_adapter": "active_job"
            }
          }
        EOF
      end

      it { expect { Namira::Async::Serializer.unserialize_request(subject) }.to_not raise_error }

      it { expect(Namira::Async::Serializer.unserialize_request(subject)).to_not be_nil }
    end

    context 'given an invalid request' do
      subject { JSON.dump(f: :bar) }
      it 'raises an error' do
        expect { Namira::Async::Serializer.unserialize_request(subject) }.to raise_error Namira::Errors::AsyncError do |error|
          expect(error.message).to eq 'key not found: "u"'
        end
      end
    end
  end

  describe '.serialize_response' do
    subject do
      Namira::Request.new(uri: 'http://echo-api.test/status/200', http_method: :post).send_request
    end

    it { expect { Namira::Async::Serializer.serialize_response(subject) }.to_not raise_error }

    it { expect(Namira::Async::Serializer.serialize_response(subject)).to_not be_nil }

    # it { puts JSON.pretty_generate(JSON.parse(Namira::Async::Serializer.serialize_response(subject))) }
  end

  describe '.unserialize_response' do
    subject do
      <<~EOF
        {
          "b": [
            200,
            {
              "Content-Type": "application/json",
              "Content-Length": "110",
              "X-Content-Type-Options": "nosniff"
            },
            "{\\"headers\\":{\\"HTTP_USER_AGENT\\":\\"Namira/1.3.0\\",\\"HTTP_CONNECTION\\":\\"close\\",\\"HTTP_HOST\\":\\"echo-api.test\\"},\\"body\\":\\"\\"}"
          ],
          "m": "post",
          "r": 0,
          "u": "http://echo-api.test/status/200",
          "v": "1.1"
        }
      EOF
    end

    it { expect { Namira::Async::Serializer.unserialize_response(subject) }.to_not raise_error }

    it { expect(Namira::Async::Serializer.unserialize_response(subject)).to_not be_nil }
  end
end
