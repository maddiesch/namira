require 'spec_helper'

describe Namira::QueryBuilder do
  it 'creates a query' do
    builder = described_class.new
    builder.q = 'test'
    builder.name = 'foo'
    expect(builder.to_s).to eq 'q=test&name=foo'
  end
end
