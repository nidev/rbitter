# encoding: utf-8
#

require "xmlrpc/server"

RPC_PREFIX="rbitter"
RPC_HANDLE_PATH=File.expand_path("./rpc")

module RPCHandles
  # intended void module
end

module Application
  class RPCServer
    def initialize bind_host, bind_port
      @rpcd = XMLRPC::Server.new(port=bind_port.to_i, host=bind_host.to_s)
      load_all_handles
      @rpcd.set_default_handler { |name, *args|
        "Unexpected command #{name} with args #{args.inspect}"
      }
    end

    def load_all_handles
      Dir.entries(RPC_HANDLE_PATH).each { |fname|
        fname = File.join(RPC_HANDLE_PATH, fname)
        if File.exist?(fname) and File.file?(fname)
          if fname.match(/rh_\w+\.rb$/)
            begin
              load fname
              namespace_length += 1
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

      puts "Checking modulespace RPCHandles, found #{RPCHandles.constants.length}"
      puts "Adding handlers..."
      RPCHandles.constants.each { |handler|
        if RPCHandles.const_get(handler).class === Class
          @rpcd.add_handler(RPC_PREFIX, RPCHandles.const_get(handler).new)
        end
      }
    end

    def main_loop
      @rpcd.serve
    end
  end
end


if __FILE__ == $0
  puts "Local testing server starts..."
  rpcd = Application::RPCServer.new('127.0.0.1', 1300)
  rpcd.main_loop
end

