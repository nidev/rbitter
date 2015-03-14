# encoding: utf-8

require "rbitter/xmlrpcd/base"

describe RPCHandles do
  context 'when RH_INFO Struct is served as RPCHandle information,' do
    it 'structs corrct Struct::RPCHANDLE_INFO' do
      # String comparison: use eq(==), not be(===)
      expect(RPCHandles::RH_INFO.to_s).to eq("Struct::RPCHANDLE_INFO")
    end

    it 'provides correct information when #digest is called' do
      digest_string = RPCHandles::RH_INFO.new('test', 0.1, 'test', 'test').digest
      expect(digest_string).to eq("<rpchandle: test-0.1 (written by test, test)>")
    end
  end
end

describe RPCHandles::BaseHandle do
  context 'when an RPCHandle inherits one of classes Auth and NoAuth' do
    it 'returns false on #auth? when an RPCHandle class inherits NoAuth' do
      expect(RPCHandles::BaseHandle::NoAuth.auth?).to be(false)
    end

    it 'returns true on #auth? when an RPCHandle class inherits Auth' do
      expect(RPCHandles::BaseHandle::Auth.auth?).to be(true)
    end
  end
end
