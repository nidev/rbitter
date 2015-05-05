# encoding: utf-8

require "rbitter/xmlrpcd/rpchandles"
require "rbitter/xmlrpcd/xmlrpc_auth_server"
require "webrick"

module Rbitter
  RPC_PREFIX="rbitter"

  class RPCServer
    def initialize bind_host, bind_port
      @server = WEBrick::HTTPServer.new(:Port => bind_port.to_i, :BindAddress => bind_host.to_s, :MaxClients => 4, :Logger => WEBrick::Log.new($stdout))
      @core = XMLRPC::HTTPAuthXMLRPCServer.new
      @core.set_default_handler { |name, *args|
        "NO_COMMAND: #{name} with args #{args.inspect}"
      }
    end

    def load_all_handles
      Rbitter["xmlrpc"]["handles"].each { |path|
        puts "[xmlrpc] Scanning handles from (#{path})"
        Dir.entries(path).each { |fname|
          fname = File.join(path, fname)
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
      }

      puts "[xmlrpc] found #{RPCHandles.constants.length} constants."
      RPCHandles.constants.each { |handler|
        if RPCHandles.const_get(handler).is_a?(Class)
          @core.add_handler(RPC_PREFIX, RPCHandles.const_get(handler).new)
        end
      }
    end

    def main_loop
      load_all_handles

      @server.mount("/", @core)
      @server.start

      puts "[xmlrpc] XMLRPC started"
    end
  end

  class DummyRPCServer
    def initialize bind_host, bind_port; end

    def load_all_handles; end

    def main_loop
      puts "[xmlrpc] DummyRPCServer started"
    end
  end

  class NullRPCServer; end
end
