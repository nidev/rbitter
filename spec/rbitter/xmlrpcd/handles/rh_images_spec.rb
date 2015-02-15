# encoding: utf-8

require "rbitter/xmlrpcd/handles/rh_images"

describe RPCHandles::ImageHost do
  it 'responds to ::auth?' do
    expect(RPCHandles::ImageHost.respond_to?(:auth?)).to be(true)
  end

  it 'does need an authentication' do
    expect(RPCHandles::ImageHost.auth?).to be(true)
  end

  it 'has \'image\' XMLRPC command' do
    expect(RPCHandles::ImageHost.instance_methods.include?(:image)).to be(true)
  end
end
