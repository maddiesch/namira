require 'spec_helper'

describe Namira::QueryBuilder do
  it 'creates a query' do
    builder = described_class.new
    builder.q = 'test'
    builder.name = 'foo'
    expect(builder.to_s).to eq 'name=foo&q=test'
  end

  it 'creates an escaped query' do
    builder = described_class.new
    builder.q = 'test'
    builder.name = 'test person'
    expect(builder.to_s).to eq 'name=test%20person&q=test'
  end

  it 'allows setting with subscripting' do
    builder = described_class.new
    builder[:foo] = 'test'
    expect(builder.to_s).to eq 'foo=test'
  end
end
