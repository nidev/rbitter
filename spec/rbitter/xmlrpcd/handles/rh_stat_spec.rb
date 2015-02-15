# encoding: utf-8

require "rbitter/xmlrpcd/handles/rh_stat"

describe RPCHandles::Statistics do
  it 'responds to ::auth?' do
    expect(RPCHandles::Statistics.respond_to?(:auth?)).to be(true)
  end

  it 'does not need an authentication' do
    expect(RPCHandles::Statistics.auth?).to be(true)
  end
end
