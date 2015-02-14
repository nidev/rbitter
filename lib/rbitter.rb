# encoding: utf-8
#

require "rbitter/version"
require "rbitter/arcserver"
require "rbitter/env"
require "rbitter/console"
require "rbitter/xmlrpc"

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
    puts "|- serve    : Launch Rbitter full system (Streaming + Database + XMLRPC)"
    puts "|- console  : Launch console application utilizing XMLRPC"
    puts "|- configure: Write default configuration file 'config.json' in current folder"
    puts "|- help     : Show this message"
    puts "`- logs     : Show Rbitter internal logs"
  end

  def self.bootstrap
    if ARGV.length == 0
      rbitter_header
    elsif ARGV[0] == "serve"
      Rbitter.config_initialize
      if Rbitter.env.empty?
        puts "No configuration available. Re-bootstrap with 'configure' command line argument."
        exit -1
      end

      main = Rbitter::ArcServer.new

      if env['xmlrpc']['enable']
        $rpc_service_thread = Thread.new {
          rpc_server = Rbitter::RPCServer.new(env['xmlrpc']['bind_host'], env['xmlrpc']['bind_port'])
          rpc_server.main_loop
        }
        $rpc_service_thread.run
      end
      main.main_loop
    elsif ARGV[0] == "configure"
      require "rbitter/default/config_json"
      puts "Writing config.json now"
      open(File.join(Dir.pwd, "config.json"), "w") { |io|
        io.write(DEFAULT_CONFIG_JSON)
      }

      puts "Writing finished"
      puts "You can move config.json one of these locations:"
      puts "[1] $HOME/config.json"
      puts "[2] $HOME/.rbitter/config.json"
      puts "[3] ./config.json (current folder)"
      puts "[4] ./.rbitter/config.json (current folder)"
      puts "For 3 and 4, you have to be in same folder to launch Rbitter."
      exit 0
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

