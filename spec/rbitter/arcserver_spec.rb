# encoding: utf-8

require "rbitter/arcserver"
require "rbitter/streaming"
require "rbitter/xmlrpcd/xmlrpcd"

describe Rbitter::ArcServer do
  it 'is presented' do
    expect(Rbitter::ArcServer).to be_a(Class)
  end

  context 'With dummy implementations, ' do
    before(:all) do
      Rbitter.bootstrap(['configure'])
      expect(File.file?('config.json')).to be(true)
    end

    it 'successfully returns from main_loop' do
      Rbitter.config_initialize

      arcserver = Rbitter::ArcServer.new(Rbitter::DummyRPCServer)
      arcserver.main_loop(Rbitter::DummyStreamClient)
    end

    after(:all) do
      File.delete('config.json')
      File.delete('rbitter.sqlite')
    end
  end
end
