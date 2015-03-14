# encoding: utf-8
#

require "rbitter/version"
require "rbitter/arcserver"
require "rbitter/env"
require "rbitter/console"
require "rbitter/xmlrpc"

module Rbitter
  def self.rbitter_header
    puts "Rbitter #{VERSION} on Ruby-#{RUBY_VERSION} (#{RUBY_PLATFORM})"
  end

  def self.rbitter_help_msg  
    puts "Rbitter is a Twitter streaming archiver, with XMLRPC access."
    puts "-------"
    puts "Usage: rbitter (application-mode)"
    puts "application-mode's are:"
    puts "|- serve    : Launch Rbitter full system (Streaming + Database + XMLRPC)"
    puts "|- console  : Launch console application utilizing XMLRPC"
    puts "|- configure: Write default configuration file 'config.json' in current folder"
    puts "|- help     : Show this message"
    puts "`- logs     : Show Rbitter internal logs"
  end

  def self.prebootstrap
    # Due to stalled socket problem, If unpatched twitter gem is installed.
    # Twitter::Streaming::Connection will be monkey-patched.
    patch_required = false

    if Twitter::Version.const_defined?(:MAJOR)
      b5_version = Twitter::Version::MAJOR * 10000
      + Twitter::Version::MINOR * 100 + Twitter::Version::PATCH
      if b5_version <= 51400
        warn "[rbitter] Monkey-patching Twitter::Streaming::Connection..."
        warn "[rbitter] Gem installed on here seemed that it doesn't handle socket read timeout."
        warn "[rbitter] Please upgrade twitter gem"
        patch_required = true
      end
    else
      b6_version = Twitter::Version.to_a
      if b6_version[0] <= 6 and b6_version[1] <= 0 and b6_version[2] <= 0
        patch_required = true
      end
    end

    require "rbitter/libtwitter_connection_override" if patch_required
  end

  def self.bootstrap args=[]
    prebootstrap

    if args.length == 0
      rbitter_header
    elsif args[0] == "serve"
      Rbitter.config_initialize

      main = Rbitter::ArcServer.new
      if env['xmlrpc']['enable']
        $rpc_service_thread = Thread.new {
          rpc_server = Rbitter::RPCServer.new(env['xmlrpc']['bind_host'], env['xmlrpc']['bind_port'])
          rpc_server.main_loop
        }
        $rpc_service_thread.run
      end
      main.main_loop
    elsif args[0] == "configure"
      require "rbitter/default/config_json"

      puts "Writing config.json now"
      open(File.join(Dir.pwd, "config.json"), "w") { |io|
        io.write(DEFAULT_CONFIG_JSON)
      }
      puts "Writing finished"
      puts "You can put config.json one of these locations:"
      puts "[1] config.json (current folder)"
      puts "[2] .rbitter/config.json (current folder)"
    elsif args[0] == "console"
      Rbitter.config_initialize

      con = Rbitter::Console.new
      con.start
    elsif args[0] == "logs"
      # show log in stdout
      puts "This feature is in heavy development. Sorry."
    else
      rbitter_header
      rbitter_help_msg
    end
  end
end
