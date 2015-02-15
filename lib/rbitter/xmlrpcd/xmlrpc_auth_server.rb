# encoding: utf-8
#

require "rbitter/xmlrpcd/rpchandles"
require "rbitter/xmlrpcd/handles/base"
require "xmlrpc/server"
require "webrick"

module XMLRPC
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
        if rpc_method.owner.ancestors.include?(RPCHandles::BaseHandle::Auth)
          # Check cookie and check it's valid
          if request.cookies.size == 1 \
            and request.cookies[0].name == "auth_key" \
            and RPCHandles.auth.include?(request.cookies[0].value)
            resp = handle(rpc_method_name, *rpc_params)
          else
            # Permission required
            raise WEBrick::HTTPStatus::Forbidden
          end
        elsif rpc_method.owner.ancestors.include?(RPCHandles::BaseHandle::NoAuth)
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