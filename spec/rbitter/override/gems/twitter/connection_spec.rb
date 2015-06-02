# encoding: utf-8
require "rbitter/libtwitter_connection_override"

describe Rbitter do
  it 'overrides twitter gem' do
    expect(Twitter::Streaming::Connection::MODIFIED).to be(true)
  end
end
