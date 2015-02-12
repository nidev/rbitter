# encoding: utf-8
#
# Rbitter Archive Access console (irb)

require "xmlrpc/client"

module Rbitter
  class Console
    def initialize
      ;
    end
    
    def exec_cmd cmd, *args
      puts "yay!"
    end

    def repl
      loop {
        print "rbitter> "
        cmdline = $stdin.gets
        if cmdline.nil? or cmdline == "exit\n"
          puts "Exit"
          break
        else
          puts "#stub#"
        end
      }
    end

    def start
      puts "Welcome to Rbitter console"
      puts "'help' will show you available methods"
      puts "^D or 'exit' to get out from here."
      repl
    end
  end
end

