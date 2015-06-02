# encoding: utf-8
require "rbitter/override/gems/twitter/connection"

describe Rbitter do
  it 'overrides twitter gem' do
    expect(Twitter::Streaming::Connection::MODIFIED).to be(true)
  end
end
