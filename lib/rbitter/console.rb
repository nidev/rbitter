# encoding: utf-8
#
# Rbitter Archive Access console (irb)

require "xmlrpc/client"
require "rbitter/version"
require "ripl"

module Rbitter
  class Console
    def initialize
      puts "Rbitter console #{Rbitter::VERSION}"
      help
    end

    def help
      puts "Predefined methods:"
      puts "ar - shortcut to call Rbitter::Record"
      puts "connect_ar - Prepare Rbitter::Record to be ready"
      puts "csv_backup - export Rbitter::Record into comma-separated values"
      puts "help - to show this message again"
      puts "xmlrpc - send xmlrpc command to destination"
      puts "xmlrpc_dest - set destination for xmlrpc command"
      puts "^D, 'exit' to exit from here"
    end

    def connect_ar
      ARSupport.connect_database
      puts "Rbitter::Record is ready."
    end

    def csv_backup *args
      if args.length < 0
        puts "Usage: csv_backup('filename.csv')"
        puts "Estimated running time depends on system environment"
      else
        ARSupport.export_to_csv(args[0])
      end
    end

    def ar
      Rbitter::Record
    end

    def exit
      Kernel.exit(0)
    end
    
    def xmlrpc_dest args={}
      if args.empty?
        puts "Usage: xmlrpc_dest({ :rpchost => '', :rpcpath => '', :rpcport => 1400,"
        puts "                   :xmlrpc_auth_id => '', xmlrpc_auth_password => '' })"
      end

      @rpchost = args.fetch(:rpchost) { "127.0.0.1" }
      @rpcpath = args.fetch(:rpcpath) { "/" }
      @rpcport = args.fetch(:rpcport) { 1400 }

      cl = XMLRPC::Client.new(@rpchost, @rpcpath, @rpcport)
      @xmlrpc_cookie = "auth_key=" + cl.call('rbitter.auth',
        args.fetch(:xmlrpc_auth_id) { Rbitter.env['xmlrpc']['auth'][0] },
        args.fetch(:xmlrpc_auth_password) { Rbitter.env['xmlrpc']['auth'][1] } )

      if @xmlrpc_cookie != "auth_key="
        puts "Authentication completed"
      else
        puts "Authentication failed"
      end
    end

    def xmlrpc *args
      if args.empty?
        puts "Usage: xmlrpc(command, [params in Array])"
        puts "Ex) xmlrpc(\'rbitter.echo\',' [\"Hello World!\"])"
        puts "Please configure XMLRPC destination with xmlrpc_dest method"
        return false
      end

      cl = XMLRPC::Client.new(@rpchost, @rpcpath, @rpcport, @xmlrpc_cookie)
      
      if args.length <= 1 or args[1].nil?
        cl.call(args[0])
      else
        cl.call(args[0], *args[1])
      end
    end

    def start
      Ripl.start :binding => binding
    end
  end
end

