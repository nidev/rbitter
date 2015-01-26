# encoding: utf-8

require "json"
require "twitter"
require_relative "records"
require_relative "streaming"
require_relative "dlthread"

module Application
  class ConfigLoader
    def initialize(cfg_filename='config.json')
      File.open(cfg_filename, "r") { |file|
        @cfg = JSON.parse(file.read)
        @cfg.freeze # no modification can be made.
      }
    end

    def method_missing(method_name, *args)
      if method_name.class == String
        method_name = method_name.to_sym
      end
      
      @cfg.__send__(method_name, *args)
    end
  end

  class RecordingServer
    def initialize
      cl = $cl
      @t = StreamClient.new(cl['twitter'].dup)
      if cl['activerecord'] == 'sqlite'
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: cl['sqlite']['dbfile'])
      elsif cl['activerecord'] == 'mysql2'
        ActiveRecord::Base.establish_connection(
          adapter: 'mysql2',
          host: cl['mysql2']['host'],
          port: cl['mysql2']['port'],
          database: cl['mysql2']['dbname'],
          username: cl['mysql2']['username'],
          password: cl['mysql2']['password'])
      else
        raise RuntimeException.new("Value of 'activerecord' option can be either sqlite or mysql2.")
      end

      if not ActiveRecord::Base.connection.table_exists?(:records)
        puts "First-time running. initiate database table..."
        init_records_table
      end

      @dt = DLThread.new(cl['media_downloader']['download_dir'], cl['media_downloader']['cacert_path'])
    end

    def write_marker(message)
      Record.create({:marker => 1,
        :marker_msg => message, 
        :userid => nil,
        :username => nil,
        :tweetid => nil,
        :tweet => nil,
        :date => nil,
        :rt_count => 0,
        :fav_count => 0})
    end

    def write_init_marker
      write_marker "recording started"
    end

    def write_halt_marker
      write_marker "recording halted"
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
            :tweet => a['tweet'], # XXX: should be url unpacked
            :date => a['date'],
            :rt_count => a['rt_count'],
            :fav_count => a['fav_count']})
          
          # Image download
          puts "#{a['screen_name']}[R#{a['rt_count']}/F#{a['fav_count']}] #{a['tweet']}"
          @dt.execute_urls(a['urls'])
        }
      rescue Interrupt => e
        puts "Interrupted..."
        exit 0
      rescue Exception => e # TODO: more specifically
        puts "Exception occured on RecordingServer. Restart within 3 seconds"
        puts e.inspect
        sleep 3
        retry
      ensure
        write_halt_marker
      end
    end
  end
end

if __FILE__ == $0
  $cl = Application::ConfigLoader.new

  if ARGV.length == 0
    main = Application::RecordingServer.new

    if $cl['xmlrpc']['enable']
      require_relative "xmlrpc"
      $rpc_service_thread = Thread.new {
        rpc_server = Application::RPCServer.new($cl['xmlrpc']['bind_host'], $cl['xmlrpc']['bind_port'])
        rpc_server.main_loop
      }

      $rpc_service_thread.abort_on_exception = true
      $rpc_service_thread.run
    end

    main.main_loop
  elsif ARGV[1] == "--console"
    # initiate console
    ;
  elsif ARGV[1] == "--retreive-log"
    # show log in stdout
    ;
  else
    ; # help message
  end
end
