# encoding: utf-8

module RPCHandles
  RH_INFO = Struct.new("RPCHANDLE_INFO", :name, :version, :author, :description) {
    def digest
      "<rpchandle: #{name}-#{version} (written by #{author}, #{description})>"
    end
  }

  module BaseHandle
    # If a handler doesn't require an authorization, please inherit below class
    class NoAuth < Object
      def self.auth?
        false
      end
    end

    # If a handler does require an authorization, please inherit below class
    class Auth < Object
      def self.auth?
        true
      end
    end
  end
end