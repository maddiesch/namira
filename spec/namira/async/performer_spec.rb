require 'spec_helper'

describe Namira::Async::Performer do
  let(:request) { Namira::Request.new(uri: 'http://echo-api.test/status/200', http_method: :post) }

  describe 'Namira::Request#send_async' do
    it { expect { request.send_async.join }.to_not raise_error }
  end
end
