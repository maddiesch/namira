require 'spec_helper'

describe Namira::Response do
  before do
    stub_request(:get, /example\.test/).to_return(status: 200, body: '{"foo":"bar"}')
  end

  subject { Namira::Request.new(uri: 'http://example.test').response }

  it { is_expected.to be_ok }

  describe '#from_json' do
    it { expect(subject.from_json).to eq 'foo' => 'bar' }
  end

  describe '#to_s' do
    it { expect(subject.to_s).to eq '{"foo":"bar"}' }
  end

  describe '#method_missing' do
    it 'raises no method error' do
      expect { subject.foo }.to raise_error NoMethodError do |e|
        expect(e.name).to eq :foo
      end
    end
  end

  describe '#respond_to_missing?' do
    it { expect(subject.respond_to?(:foo)).to be false }
  end
end
