require 'spec_helper'

describe Namira::Config do
  describe 'default values' do
    subject { described_class.new }

    describe '#max_redirect' do
      it { expect(subject.max_redirect).to eq 3 }
    end

    describe '#timeout' do
      it { expect(subject.timeout).to eq 5.0 }
    end

    describe '#backend' do
      it { expect(subject.backend).to be_nil }
    end

    describe '#user_agent' do
      it { expect(subject.user_agent).to eq "Namira/#{Namira::VERSION}" }
    end

    describe '#headers' do
      it { expect(subject.headers).to be_a(Hash) }
      it { expect(subject.headers.to_h).to be_empty }
    end

    describe '#log_requests' do
      it { expect(subject.log_requests).to eq true }
    end

    describe '#async_adapter' do
      it { expect(subject.async_adapter).to eq :active_job }
    end

    describe '#async_queue_name' do
      it { expect(subject.async_queue_name).to eq :default }
    end
  end
end
