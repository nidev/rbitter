# encoding: utf-8

require "rbitter/xmlrpcd/rpchandles"
require "rbitter/xmlrpcd/xmlrpc_auth_server"
require "webrick"

module Rbitter
  RPC_PREFIX="rbitter"
  RPC_HANDLE_PATH=File.expand_path("../handles", __FILE__)

  class RPCServer
    def initialize bind_host, bind_port
      @server = WEBrick::HTTPServer.new(:Port => bind_port.to_i, :BindAddress => bind_host.to_s, :MaxClients => 4, :Logger => WEBrick::Log.new($stdout))
      @core = XMLRPC::HTTPAuthXMLRPCServer.new
      load_all_handles
      @core.set_default_handler { |name, *args|
        "NO_COMMAND: #{name} with args #{args.inspect}"
      }
    end

    def load_all_handles
      Dir.entries(RPC_HANDLE_PATH).each { |fname|
        fname = File.join(RPC_HANDLE_PATH, fname)
        if File.exist?(fname) and File.file?(fname)
          if fname.match(/rh_\w+\.rb$/)
            begin
              load fname
            rescue Exception => e
              # stub
              puts "Exception while loading #{fname}"
              puts e.inspect
            end
          else
            puts "Ignored: #{fname}"
          end
        end
      }

      puts "modulespace RPCHandles, found #{RPCHandles.constants.length} constants."
      RPCHandles.constants.each { |handler|
        if RPCHandles.const_get(handler).is_a?(Class)
          @core.add_handler(RPC_PREFIX, RPCHandles.const_get(handler).new)
        end
      }
    end

    def main_loop
      puts "RPCServer starts"
      @server.mount("/", @core)
      @server.start
    end
  end
end


if __FILE__ == $0
  puts "Local testing server starts..."
  rpcd = Rbitter::RPCServer.new('127.0.0.1', 1300)
  rpcd.main_loop
end

