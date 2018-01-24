require 'spec_helper'

describe Namira::Request do
  describe 'sending requests' do
    context 'given a valid uri' do
      let(:request) { described_class.new(uri: 'http://example.test/') }

      subject { request.response }

      before do
        stub_request(:get, /example\.test/).to_return(status: 200, body: '{}')
      end

      it 'fetches data and returns a 200' do
        expect(subject.status).to eq 200
      end

      it 'fetches data and returns a body' do
        expect(subject.body.to_s).to eq '{}'
      end
    end

    context 'given an invalid uri' do
      let(:request) { described_class.new(uri: 'http://foo bar.test/') }

      it 'raises a Namira::Errors::InvalidURIError' do
        expect { request.response }.to raise_error Namira::Errors::InvalidURIError
      end
    end

    %w[400 422 500].each do |status|
      context "given a response with a status of #{status}" do
        let(:request) { described_class.new(uri: 'http://example.test/') }

        before do
          stub_request(:get, /example\.test/).to_return(status: status.to_i, body: '{}')
        end

        it "raises a http_error/#{status}" do
          expect { request.response }.to raise_error(Namira::Errors::HTTPError) do |e|
            expect(e.message).to match /^http_error\/#{status}/
          end
        end
      end
    end

    context 'given additional headers' do
      let(:request) do
        described_class.new(
          uri: 'http://example.test/',
          http_method: :post,
          body: JSON.dump({}),
          headers: { 'Authorization' => 'Bearer 123' }
        )
      end

      subject { request.response }

      before do
        stub_request(:post, /example\.test/).with(body: '{}', headers: { 'Authorization' => 'Bearer 123' })
      end

      it 'sends headers' do
        expect(subject.status).to be_ok
      end
    end

    describe 'redirect following' do
      subject { request.response }

      before do
        stub_request(:get, /example\.test/).to_return(status: 301, headers: { 'Location' => 'http://example.test/1' })
        stub_request(:get, /example\.test\/1/).to_return(status: 301, headers: { 'Location' => 'http://example.test/2' })
        stub_request(:get, /example\.test\/2/).to_return(status: 301, headers: { 'Location' => 'http://example.test/3' })
        stub_request(:get, /example\.test\/3/).to_return(status: 301, headers: { 'Location' => 'http://example.test/4' })
        stub_request(:get, /example\.test\/4/).to_return(status: 200)
      end

      context 'given enough redirects' do
        let(:request) do
          described_class.new(
            uri: 'http://example.test/',
            http_method: :get,
            config: {
              max_redirect: 10
            }
          )
        end

        it { is_expected.to be_ok }
      end

      context 'given limited redirects' do
        let(:request) do
          described_class.new(
            uri: 'http://example.test/',
            http_method: :get,
            config: {
              max_redirect: 1
            }
          )
        end

        it 'raises a Namira::Errors::RedirectError' do
          expect { subject }.to raise_error Namira::Errors::RedirectError
        end
      end

      context 'given no follow' do
        let(:request) do
          described_class.new(
            uri: 'http://example.test/',
            http_method: :get,
            config: {
              follow_redirect: false
            }
          )
        end

        it 'raises a Namira::Errors::HTTPError' do
          expect { subject }.to raise_error Namira::Errors::HTTPError do |e|
            expect(e.status).to eq 301
          end
        end
      end

      context 'given a malformed location' do
        before do
          stub_request(:get, /example\.test/).to_return(status: 301, headers: {})
        end

        let(:request) do
          described_class.new(
            uri: 'http://example.test/',
            http_method: :get
          )
        end

        it 'raises a Namira::Errors::RedirectError' do
          expect { subject }.to raise_error Namira::Errors::RedirectError do |e|
            expect(e.message).to eq 'Request redirected but no location was supplied'
          end
        end
      end
    end

    context 'given global headers' do
      let(:request) { described_class.new(uri: 'http://example.test/', headers: { 'Foo' => 'Bar' }) }

      subject { request.response }

      before do
        Namira.configure do |c|
          c.headers.test_header = 'Foo'
        end
        stub_request(:get, /example\.test/).with(headers: { 'Test-Header' => 'Foo', 'Foo' => 'Bar' })
      end

      after do
        Namira.configure do |c|
          c.headers = OpenStruct.new
        end
      end

      it 'fetches data and returns a 200' do
        expect(subject.status).to eq 200
      end
    end

    context 'given a timeout' do
      let(:request) { described_class.new(uri: 'http://example.test/') }

      before do
        stub_request(:get, /example\.test/).to_timeout
      end

      it 'raises a Namira::Errors::TimeoutError' do
        expect { request.send_request }.to raise_error Namira::Errors::TimeoutError
      end
    end

    describe 'logging enabled' do
      before do
        Namira.configure.log_requests = true
        stub_request(:get, /example\.test/)
      end

      after { Namira.configure.log_requests = false }

      let(:request) { described_class.new(uri: 'http://example.test/') }

      context 'without rails' do
        it 'loggs to puts' do
          expect(STDOUT).to receive(:puts).with('GET - http://example.test/')
          request.send_request
        end
      end

      context 'with rails' do
        before do
          klass = Class.new Object do; end
          Object.const_set 'Rails', klass
        end

        after { Object.send :remove_const, :Rails }

        it 'loggs to debug' do
          rails = double
          logger = double
          expect(Rails).to receive(:logger).and_return(logger)
          expect(logger).to receive(:debug).with('GET - http://example.test/')
          request.send_request
        end
      end

      context 'per-request disabling' do
        let(:request) do
          described_class.new(
            uri: 'http://example.test/',
            config: {
              Namira::Middleware::Logger::SKIP_LOGGING_KEY => true
            }
          )
        end

        it 'loggs to puts' do
          expect(STDOUT).to_not receive(:puts)
          request.send_request
        end
      end
    end
  end
end
