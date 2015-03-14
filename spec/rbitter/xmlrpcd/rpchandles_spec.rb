# encoding: utf-8
require "rbitter/xmlrpcd/rpchandles"

describe RPCHandles do
  context 'When features related to authentication needs ::auth method,'
  it 'responds to ::auth' do
    expect(RPCHandles.respond_to?(:auth)).to be(true)
    expect(RPCHandles.auth).to be_a(NilClass)
  end
end
