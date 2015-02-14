# encoding: utf-8

require "rbitter/rpc/rh_last_active"

describe RPCHandles::LastActiveTime do
  it 'responds to ::auth?' do
    expect(RPCHandles::LastActiveTime.respond_to?(:auth?)).to be(true)
  end

  it 'does need an authentication' do
    expect(RPCHandles::LastActiveTime.auth?).to be(true)
  end

  it 'has \'last_active\' XMLRPC command' do
    expect(RPCHandles::LastActiveTime.instance_methods.include?(:last_active)).to be(true)
  end
end
