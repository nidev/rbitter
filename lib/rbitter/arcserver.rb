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

    def initialize
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

      @t = StreamClient.new(Rbitter['twitter'].dup)
      @dt = DLThread.new(
        Rbitter['media_downloader']['download_dir'],
        Rbitter['media_downloader']['cacert_path'],
        Rbitter['media_downloader']['large_image'])
    end

    def mark(code, message)
      Record.create({:marker => code,
        :marker_msg => message, 
        :userid => nil,
        :username => nil,
        :tweetid => nil,
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

    def main_loop
      begin
        write_init_marker
        @t.run { |a|
          record = Record.find_or_initialize_by(tweetid: a['tweetid'])
          record.update({:marker => 0,
            :marker_msg => "normal", 
            :userid => a['userid'],
            :username => a['screen_name'],
            :tweetid => a['tweetid'],
            :tweet => a['tweet'],
            :date => a['date'],
            :rt_count => a['rt_count'],
            :fav_count => a['fav_count']})

          record.save
          @dt.execute_urls(a['media_urls'])
        }
      rescue Interrupt => e
        puts ""
        puts "Interrupted..."
        if Rbitter['xmlrpc']['enable']
          puts "Finishing RPCServer"
          if $rpc_service_thread.alive?
            $rpc_service_thread.terminate
            $rpc_service_thread.join
          end
        end
        exit 0
      rescue Twitter::Error::Unauthorized => e
        puts "Please configure your Twitter token on config.json."
        exit -1
      rescue Twitter::Error::ServerError, Resolv::ResolvError => e
        puts "Service unavailable now. Retry in 5 second..."
        sleep 5
        retry
      rescue Twitter::Error => e
        puts "Twitter Error: #{e.inspect}"
        exit -1
      ensure
        write_halt_marker
      end
    end
  end
end
