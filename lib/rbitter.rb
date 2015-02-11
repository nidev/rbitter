# encoding: utf-8
#

require "rbitter/version"
require "rbitter/arcserver"
require "rbitter/cfgloader"
require "rbitter/console"

module Rbitter
  # Your code goes here...
  #
  def self.rbitter_header
    puts "Rbitter #{VERSION} on Ruby-#{RUBY_VERSION} (#{RUBY_PLATFORM})"
  end

  def self.rbitter_help_msg  
    puts "Rbitter is a Twitter streaming archiver, with XMLRPC access."
    puts "-------"
    puts "Usage: #{__FILE__} application-mode"
    puts "application-mode's are:"
    puts "|- serve  : Launch Rbitter full system (Streaming + Database + XMLRPC)"
    puts "|- console: Launch console application utilizing XMLRPC"
    puts "|- help: Show this message"
    puts "`- logs: Show Rbitter internal logs"
  end

  def self.bootstrap
    cfg = Rbitter::ConfigLoader.new
    
    if ARGV.length == 0
      rbitter_header
    elsif ARGV[0] == "serve"
      main = Rbitter::ArcServer.new

      if cfg['xmlrpc']['enable']
        $rpc_service_thread = Thread.new {
          rpc_server = Rbitter::RPCServer.new(cfg['xmlrpc']['bind_host'], cfg['xmlrpc']['bind_port'])
          rpc_server.main_loop
        }
        $rpc_service_thread.run
      end
      main.main_loop
    elsif ARGV[0] == "console"
      # initiate console
      puts "Start Rbitter console..."
      con = Rbitter::Console.new
      con.start
    elsif ARGV[0] == "logs"
      # show log in stdout
      puts "This feature is in heavy development. Sorry."
    else
      rbitter_header
      rbitter_help_msg
    end
  end
end

