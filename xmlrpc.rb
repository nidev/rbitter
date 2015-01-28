# encoding: utf-8
#

require "xmlrpc/server"
require "webrick"
require_relative "rpc/base"

RPC_PREFIX="rbitter"
RPC_HANDLE_PATH=File.expand_path("./rpc")

module RPCHandles
  # intended void module
end

module XMLRPC
  class HTTPAuthWEBrickServlet < WEBrickServlet
    def service(request, response)
      # XXX:
      # Taken from xmlrpc/server.rb, will be modified.
      if @valid_ip
        raise WEBrick::HTTPStatus::Forbidden unless @valid_ip.any? { |ip| request.peeraddr[3] =~ ip }
      end

      if request.request_method != "POST"
        raise WEBrick::HTTPStatus::MethodNotAllowed,
              "unsupported method `#{request.request_method}'."
      end

      if parse_content_type(request['Content-type']).first != "text/xml"
        raise WEBrick::HTTPStatus::BadRequest
      end

      length = (request['Content-length'] || 0).to_i

      raise WEBrick::HTTPStatus::LengthRequired unless length > 0

      data = request.body

      if data.nil? or data.bytesize != length
        raise WEBrick::HTTPStatus::BadRequest
      end

      # TODO: Make a custom 'process' function, To handle Auth/NoAuth
      resp = process(data)
      if resp.nil? or resp.bytesize <= 0
        raise WEBrick::HTTPStatus::InternalServerError
      end

      response.status = 200
      response['Content-Length'] = resp.bytesize
      response['Content-Type']   = "text/xml; charset=utf-8"
      response.body = resp
    end
  end
end

module Application
  class NoRPCAccessPermission < Exception
  end

  class RPCServer
    def initialize bind_host, bind_port
      @auth_pool = {} # PairOf { AuthKey => AuthDate }

      @server = WEBrick::HTTPServer.new(:Port => bind_port.to_i, :BindAddress => bind_host.to_s, :MaxClients => 4, :Logger => WEBrick::Log.new($stdout))
      @core = XMLRPC::HTTPAuthWEBrickServlet.new
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

      puts "Checking modulespace RPCHandles, found #{RPCHandles.constants.length}"
      puts "Adding handlers..."
      RPCHandles.constants.each { |handler|
        if RPCHandles.const_get(handler).class === Class
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
  rpcd = Application::RPCServer.new('127.0.0.1', 1300)
  rpcd.main_loop
end

    
