require 'spec_helper'

describe Namira do
  it 'has a version number' do
    expect(Namira::VERSION).not_to be nil
  end

  context 'sets default config values' do
    it { expect(Namira.configure.max_redirect).to eq 3 }
    it { expect(Namira.configure.timeout).to eq 5.0 }
    it { expect(Namira.configure.backend).to be_nil }
    it { expect(Namira.configure.user_agent).to eq "Namira/#{Namira::VERSION}" }
  end
end
