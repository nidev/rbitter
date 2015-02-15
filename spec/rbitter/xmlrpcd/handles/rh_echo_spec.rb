# encoding: utf-8

require "rbitter/xmlrpcd/handles/rh_echo"

describe RPCHandles::Echo do
  it 'responds to ::auth?' do
    expect(RPCHandles::Echo.respond_to?(:auth?)).to be(true)
  end

  it 'does need an authentication' do
    expect(RPCHandles::Echo.auth?).to be(true)
  end

  it 'has \'echo\' XMLRPC command' do
    expect(RPCHandles::Echo.instance_methods.include?(:echo)).to be(true)
  end
end
