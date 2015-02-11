# encoding: utf-8
#

require "xmlrpc/server"
require "webrick"
require_relative "rpc/base"

module Rbitter
  class HTTPAuthXMLRPCServer < XMLRPC::WEBrickServlet
    def extract_method(methodname, *args)
      for name, obj in @handler
        if obj.kind_of? Proc
          next unless methodname == name
        else
          next unless methodname =~ /^#{name}(.+)$/
          next unless obj.respond_to? $1
          return obj.method($1)
        end
      end
      nil
    end

    def service(request, response)
      # Taken from xmlrpc/server.rb
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

      # Originally, process(data) was here.
      # We need to check whether a method requires authorization.
      rpc_method_name, rpc_params = parser().parseMethodCall(data)
      rpc_method = extract_method(rpc_method_name)

      if RPCHandles.auth.nil?
        resp = handle(rpc_method_name, *rpc_params)
      else
        if rpc_method.owner.ancestors.include?(Auth)
          # Check cookie and check it's valid
          if request.cookies.size == 1 \
            and request.cookies[0].name == "auth_key" \
            and RPCHandles.auth.include?(request.cookies[0].value)
            resp = handle(rpc_method_name, *rpc_params)
          else
            # Permission required
            raise WEBrick::HTTPStatus::Forbidden
          end
        elsif rpc_method.owner.ancestors.include?(NoAuth)
          resp = handle(rpc_method_name, *rpc_params)
        else
          raise WEBrick::HTTPStatus::Forbidden
        end
      end

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

module Rbitter
  RPC_PREFIX="rbitter"
  RPC_HANDLE_PATH=File.expand_path("./rpc")

  module RPCHandles
    # Override this function will activate authentication feature.
    # You can write and add RPCHandle. See 'rpc' folder.

    @@auth_pool = nil
    module_function
    def auth
      @@auth_pool
    end
  end

  class RPCServer
    def initialize bind_host, bind_port
      @auth_pool = {} # PairOf { AuthKey => AuthDate }

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
  rpcd = Rbitter::RPCServer.new('127.0.0.1', 1300)
  rpcd.main_loop
end

