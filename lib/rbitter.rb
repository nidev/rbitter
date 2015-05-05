# encoding: utf-8
#

require "rbitter/version"
require "rbitter/arcserver"
require "rbitter/env"
require "rbitter/console"
require "rbitter/xmlrpc"

module Rbitter
  BOOTSTRAP_ARGS = ['configure', 'console', 'help', 'logs', 'serve']

  def self.rbitter_header
    puts "Rbitter #{VERSION} on #{RUBY_VERSION} (#{RUBY_PLATFORM})"
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
        warn "[rbitter] Monkey-patching Twitter::Streaming::Connection"
        warn "[rbitter] Please upgrade twitter gem to apply streaming read timeout"
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

  def self.bootstrap_configs
    require "rbitter/default/config_json"

    open(File.join(Dir.pwd, "config.json"), "w") { |io|
      io.write(DEFAULT_CONFIG_JSON)
    }
  end

  def self.bootstrap args=[]
    return nil if args.length < 1
    
    if args[0] == "serve"
      prebootstrap

      Rbitter.config_initialize
      
      archive_server = Rbitter::ArcServer.new
      archive_server.main_loop
    elsif args[0] == "help"
      rbitter_help_msg
    elsif args[0] == "configure"
      bootstrap_configs
    elsif args[0] == "console"
      Rbitter.config_initialize

      con = Rbitter::Console.new
      con.start
    elsif args[0] == "logs"
      # show log in stdout
      puts "Log buffer feature is in heavy development. Sorry."
    else
      fail StandardError, "Invalid bootstrap parameter: #{args[0]}"
    end
  end
end
