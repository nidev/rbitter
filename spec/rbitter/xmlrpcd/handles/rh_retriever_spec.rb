# encoding: utf-8

require "rbitter/rpc/rh_retriever"

describe RPCHandles::Retriever do
  it 'responds to ::auth?' do
    expect(RPCHandles::Retriever.respond_to?(:auth?)).to be(true)
  end

  it 'does need an authentication' do
    expect(RPCHandles::Retriever.auth?).to be(true)
  end

  # So many methods in there. What can I do for making the test correct?
end
