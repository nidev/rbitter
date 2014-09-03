# encoding: utf-8

require "json"
require "twitter"
require "./database"
require "./streaming"
require "./dlthread"

module Application
	class ConfigLoader
		def initialize(cfg_filename='config.json')
			File.open(cfg_filename, "r") { |file|
				@cfg = JSON.parse(file.read)
			}
		end

		def method_missing(method_name, *args)
			if method_name.class == String
				method_name = method_name.to_sym
			end
			
			@cfg.__send__(method_name, *args)
		end
	end

	class Main
		def initialize
			@cl = ConfigLoader.new
			@t = StreamClient.new(@cl['twitter'].dup)
			@d = Database::DBHandler.new(:host => @cl['mysql2']['host'], :port => @cl['mysql2']['port'], :dbname => @cl['mysql2']['dbname'])
			@d.link(@cl['mysql2']['username'], @cl['mysql2']['password'])
			@d.create_if_not_exists(@cl['mysql2']['tablename'])
			@tablename = @cl['mysql2']['tablename']

			@dt = DLThread.new(@cl['media_downloader']['download_dir'], @cl['media_downloader']['cacert_path'])
		end

		def write_marker(message)
			@d.insert_into(@tablename, :id => nil,
        :marker => 1,
        :marker_msg => message, 
        :userid => nil,
        :username => nil,
        :tweetid => nil,
        :tweet => nil,
        :date => nil,
        :rt_count => 0,
        :fav_count => 0)
		end

		def write_init_marker
			write_marker "recording started"
		end

		def write_halt_marker
			write_marker "recording halted"
		end

		def run
			write_init_marker
			@t.run { |a|
				@d.insert_into(@tablename, :id => nil,
					:marker => 0,
					:marker_msg => "normal", 
					:userid => a['userid'],
					:username => a['screen_name'],
					:tweetid => a['tweetid'],
					:tweet => a['tweet'],
					:date => a['date'],
					:rt_count => a['rt_count'],
					:fav_count => a['fav_count'])
				
				# Image download
				puts a['tweet']
				@dt.execute_urls(a['urls'])
			}
			write_halt_marker
		end
	end
end

if __FILE__ == $0
	main = Application::Main.new
	main.run
end
