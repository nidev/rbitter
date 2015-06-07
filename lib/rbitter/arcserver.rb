# encoding: utf-8

require "json"
require "date"
require "twitter"
require "resolv"

require "rbitter/records"
require "rbitter/streaming"
require "rbitter/dlthread"
require "rbitter/xmlrpc"
require "rbitter/progress"

module Rbitter
  class ArcServer
    include Progress

    LOG_NORMAL = 0
    LOG_INIT = 1
    LOG_HALT = 2
    LOG_ERROR = 4

    def initialize(xmlrpcd_class = Rbitter::RPCServer)
      @xmlrpcd_class = xmlrpcd_class
      @dt = DLThread.new(
        Rbitter['media_downloader']['download_dir'],
        Rbitter['media_downloader']['large_image'])
    end

    def arsupport_init
      ARSupport.connect_database

      if not ARSupport.prepared?
        puts "Initiate database table..."
        if Rbitter['activerecord'] == 'mysql2'
          ARSupport.prepare "DEFAULT CHARSET=utf8mb4"
        else
          ARSupport.prepare
        end
      end

      ARSupport.update_database_scheme
    end

    def arsupport_halt
      ARSupport.disconnect_database
    end

    def xmlrpcd_start
      if Rbitter['xmlrpc']['enable']
        @rpc_service = Thread.new {
          rpc_server = @xmlrpcd_class.new(Rbitter['xmlrpc']['bind_host'], Rbitter['xmlrpc']['bind_port'])
          rpc_server.main_loop
        }
      else
        @rpc_service = nil
      end
    end

    def xmlrpcd_stop
      unless @rpc_service.nil?
        if @rpc_service.alive?
          puts "Finishing RPCServer (impl: #{@xmlrpcd_class})"
          @rpc_service.terminate
          @rpc_service.join
          @rpc_service = nil
        end
      end
    end

    def mark(code, message)
      Record.create({:marker => code,
        :marker_msg => message, 
        :userid => nil,
        :username => nil,
        :tweetid => nil,
        :replyto => nil,
        :tweet => nil,
        :date => ARSupport.any_to_datestring(DateTime.now),
        :rt_count => 0,
        :fav_count => 0})
    end

    def mark_init
      mark(LOG_INIT, "Archiving service started")
    end

    def mark_halt
      mark(LOG_HALT, "Archiving service halted")
    end

    def mark_error(exception_string, err_msg)
      mark(LOG_ERROR, "Errored (#{exception_string}, #{err_msg}")
    end

    def resurrect_loop?
      if Rbitter.env['twitter']['connection']['reconnect']
        puts "[rbitter] Try to reconnect..."
        sleep Rbitter.env['twitter']['connection']['timeout_secs']
        true
      else
        puts "[rbitter] Give up!"
        false
      end
    end

    def main_loop(streaming_adapter = Rbitter::StreamClient)
      xmlrpcd_start if Rbitter['xmlrpc']['enable']

      arsupport_init

      begin
        mark_init

        streaming_adapter.new(Rbitter['twitter']).run { |a|
          @dt << a['media_urls']

          record = Record.find_or_initialize_by(tweetid: a['tweetid'])
          record.update({:marker => 0,
            :marker_msg => "normal", 
            :userid => a['userid'],
            :username => a['screen_name'],
            :tweetid => a['tweetid'],
            :replyto => a['replyto'],
            :tweet => a['tweet'],
            :date => a['date'],
            :rt_count => a['rt_count'],
            :fav_count => a['fav_count']})

          record.save
          draw "[rbitter] saving tweet: #{a['tweetid']}"
        }
      rescue Interrupt => e
        puts ""
        puts "Interrupted..."
        mark_error(e.to_s, "(exit) SIGINT - interrupted by user")
      rescue Twitter::Error::Unauthorized => e
        warn "Twitter access unauthorized:"
        warn "  Possible solutions"
        warn "  1. Configure Twitter token on config.json"
        warn "  2. Check system time (Time is important on authentication)"
        warn "  3. Check Twitter account status"
      rescue Twitter::Error::ServerError => e
        puts "Service unavailable now. Retry in 5 seconds..."
        mark_error(e.to_s, "(retry) Twitter server unavailable / Timeout")

        retry if resurrect_loop?
      rescue Resolv::ResolvError, Errno::ECONNABORTED,
        Errno::ECONNREFUSED, Errno::ECONNRESET => e
        puts "Network problem. Retry in 5 seconds..."
        mark_error(e.to_s, "(retry) Network problem")

        retry if resurrect_loop?
      rescue Twitter::Error => e
        warn "Twitter Error: #{e.inspect}"
        warn "Rbitter halts due to Twitter::Error"
        mark_error(e.to_s, "(exit) Twitter Error")
      ensure
        xmlrpcd_stop if Rbitter['xmlrpc']['enable']
        @dt.job_cleanup

        mark_halt
      end

      arsupport_halt
    end

  end
end
