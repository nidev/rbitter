# encoding: utf-8
#
# Rbitter Archive Access console (irb)

require "xmlrpc/client"
require "ripl"

module Rbitter
  class Console
    def initialize
      puts "Welcome to Rbitter console"
    end

    def help
      puts "Predefined methods:"
      puts "help - to show this message again"
      puts "xmlrpc - to utilize xmlrpc"
      puts "activerec - to connect and utilize Rbitter::Record ActiveRecord"
      puts "^D, 'exit' - to get out from here."
    end

    def activerec
      ARSupport.connect_database
      puts "ActiveRecord::Record is ready."
    end

    def exit
      Kernel.exit(0)
    end
    
    def xmlrpc *args
      if args.empty?
        puts "How to use: xmlrpc (command) [params in Array]"
        puts "Ex) xmlrpc rbitter.echo [\"Hello World!\"]"
        puts "Ex) To call XMLRPC function with zero parameter, use nil."
        return false
      end

      cl = XMLRPC::Client.new('localhost', '/', 1400) # TODO: External address?
      if @xmlrpc_cookie.nil?
        @xmlrpc_cookie = "auth_key=" + cl.call('rbitter.auth', Rbitter.env['xmlrpc']['auth'][0], Rbitter.env['xmlrpc']['auth'][1])
      end
      
      if cl.cookie != "auth_key="
        if args.length <= 1 or args[1].nil?
          cl.call(args[0])
        else
          cl.call(args[0], *args[1])
        end
      else
        puts "Authentication failed. Check your config.json"
      end
    end

    def start
      Ripl.start :binding => binding
    end
  end
end

