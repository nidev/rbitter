# encoding: utf-8

require "rbitter/rpc/rh_auth"

describe RPCHandles::Authentication do
  it 'responds to ::auth?' do
    expect(RPCHandles::Authentication.respond_to?(:auth?)).to be(true)
  end

  it 'does not need an authentication' do
    expect(RPCHandles::Authentication.auth?).to be(false)
  end

  it 'has \'auth\' XMLRPC command' do
    expect(RPCHandles::Authentication.instance_methods.include?(:auth)).to be(true)
  end
end
