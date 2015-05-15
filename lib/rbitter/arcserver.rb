# encoding: utf-8

require "json"
require "date"
require "twitter"
require "resolv"

require "rbitter/records"
require "rbitter/streaming"
require "rbitter/dlthread"
require "rbitter/xmlrpc"

module Rbitter
  class ArcServer
    LOG_NORMAL = 0
    LOG_INIT = 1
    LOG_HALT = 2

    def initialize(xmlrpcd_class = Rbitter::RPCServer)
      @xmlrpcd_class = xmlrpcd_class

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

      @dt = DLThread.new(
        Rbitter['media_downloader']['download_dir'],
        Rbitter['media_downloader']['large_image'])
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

    def write_init_marker
      mark(LOG_INIT, "Archiving service started")
    end

    def write_halt_marker
      mark(LOG_HALT, "Archiving service halted")
    end

    def main_loop(streaming_adapter = Rbitter::StreamClient)
      xmlrpcd_start if Rbitter['xmlrpc']['enable']

      begin
        write_init_marker

        streaming_adapter.new(Rbitter['twitter'].dup).run { |a|
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
        }
      rescue Interrupt => e
        puts ""
        puts "Interrupted..."
      rescue Twitter::Error::Unauthorized => e
        puts "Please configure your Twitter token on config.json."
      rescue Twitter::Error::ServerError, Resolv::ResolvError => e
        puts "Service unavailable now. Retry in 5 second..."
        sleep 5
        retry
      rescue Twitter::Error => e
        puts "Twitter Error: #{e.inspect}"
      ensure
        xmlrpcd_stop if Rbitter['xmlrpc']['enable']
        @dt.job_cleanup

        write_halt_marker
      end
    end
  end
end
