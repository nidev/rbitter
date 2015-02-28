# encoding: utf-8

describe Rbitter do
  it 'overrides twitter gem' do
    require "rbitter/libtwitter_connection_override"
    expect(Twitter::Streaming::Connection.MODIFIED).to be(true)
  end
end
