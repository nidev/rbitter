# encoding: utf-8

require "json"
require "date"
require "twitter"

require_relative "cfgloader"
require_relative "records"
require_relative "streaming"
require_relative "dlthread"
require_relative "xmlrpc"

module Application
  class ArcServer
    def initialize
      @cl = ConfigLoader.new

      @t = StreamClient.new(@cl['twitter'].dup)
      if @cl['activerecord'] == 'sqlite3'
        puts "Warning: If you enable XMLRPC access, using sqlite is not recommended."
        puts "Warning: Random crash can happen because of concurrency."
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: @cl['sqlite3']['dbfile'], timeout: 10000) # On some slow computer.
      elsif @cl['activerecord'] == 'mysql2'
        ActiveRecord::Base.establish_connection(
          adapter: 'mysql2',
          host: @cl['mysql2']['host'],
          port: @cl['mysql2']['port'],
          database: @cl['mysql2']['dbname'],
          username: @cl['mysql2']['username'],
          password: @cl['mysql2']['password'],
          encoding: "utf8mb4",
          collation: "utf8mb4_unicode_ci")
      else
        raise RuntimeException.new("Unknown configuration value. 'activerecord' value should be sqlite3 or mysql2.")
      end

      if not ARSupport.prepared?
        puts "Initiate database table..."
        if @cl['activerecord'] == 'mysql2'
          ARSupport.prepare "DEFAULT CHARSET=utf8mb4"
        else
          ARSupport.prepare
        end
      end

      @dt = DLThread.new(@cl['media_downloader']['download_dir'], @cl['media_downloader']['cacert_path'])
    end

    def write_marker(message)
      Record.create({:marker => 1,
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
      write_marker "Archiving service started"
    end

    def write_halt_marker
      write_marker "Archiving service halted"
    end

    def main_loop
      begin
        write_init_marker
        @t.run { |a|
          Record.create({:marker => 0,
            :marker_msg => "normal", 
            :userid => a['userid'],
            :username => a['screen_name'],
            :tweetid => a['tweetid'],
            :tweet => a['tweet'],
            :date => a['date'],
            :rt_count => a['rt_count'],
            :fav_count => a['fav_count']})
          
          # Image download
          #puts "#{a['screen_name']}[R#{a['rt_count']}/F#{a['fav_count']}] #{a['tweet']}"
          @dt.execute_urls(a['urls'])
        }
      rescue Interrupt => e
        puts ""
        puts "Interrupted..."
        if @cl['xmlrpc']['enable']
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
      rescue Twitter::Error::ServerError => e
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
