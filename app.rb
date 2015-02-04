# encoding: utf-8

require_relative "cfgloader"
require_relative "arcserver"

module Application
  def self.VERSION
    0.2
  end
end

def rbitter_header
  puts "Rbitter #{Application.VERSION} on Ruby-#{RUBY_VERSION} (#{RUBY_PLATFORM})"
end

def rbitter_help_msg  
  puts "Rbitter is a Twitter streaming archiver, with XMLRPC access."
  puts "-------"
  puts "Usage: #{__FILE__} application-mode"
  puts "application-mode's are:"
  puts "|- serve  : Launch Rbitter full system (Streaming + Database + XMLRPC)"
  puts "|- console: Launch console application utilizing XMLRPC"
  puts "|- help: Show this message"
  puts "`- logs: Show Rbitter internal logs"
end

if __FILE__ == $0
  cfg = Application::ConfigLoader.new
  
  if ARGV.length == 0
    rbitter_header
  elsif ARGV[0] == "serve"
    main = Application::ArcServer.new

    if cfg['xmlrpc']['enable']
      $rpc_service_thread = Thread.new {
        rpc_server = Application::RPCServer.new(cfg['xmlrpc']['bind_host'], cfg['xmlrpc']['bind_port'])
        rpc_server.main_loop
      }
      $rpc_service_thread.run
    end
    main.main_loop
  elsif ARGV[0] == "console"
    # initiate console
    require_relative "console"

    puts "Start Rbitter console..."
    con = Application::Console.new
    con.start
  elsif ARGV[0] == "logs"
    # show log in stdout
    puts "This feature is in heavy development. Sorry."
  else
    rbitter_header
    rbitter_help_msg
  end
end

