# encoding: utf-8
#

require "xmlrpc/server"

module Application
  class RPCServer
    def initialize bind_host, bind_port
      @rpcd = XMLRPC::Server.new(port=bind_port.to_i, host=bind_host.to_s)
      %q{
      rpc.auth
      rpc.invoke
      rpc.server_status
      rpc.last_active
      rpc.ret_with_ranges
      rpc.echo
      }
      @rpcd.add_handler("xmlrpc.hello") {
        "Hello World"
      }
      @rpcd.add_handler("xmlrpc.echo") { |t|
        t
      }
      @rpcd.set_default_handler { |name, *args|
        "Unexpected command #{name} with args #{args.inspect}"
      }
    end

    def main_loop
      @rpcd.serve
    end
  end
end


if __FILE__ == $0
  rpcd = Application::RPCServer.new('127.0.0.1', 1300)
  rpcd.main_loop
end

