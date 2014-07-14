# encoding: utf-8

require "json"
require "twitter"
require "./database"
require "./streaming"

module Application
	class ConfigLoader
		attr_accessor :cfg

		def initialize(cfg_filename='config.json')
			File.open(cfg_filename, "r") { |file|
				@cfg = JSON.parse(file.read)
			}
		end
	end

	class Main
		def initialize
			@c = ConfigLoader.new
			t = @c.cfg['twitter']
			@t = StreamClient.new(t['consumer_key'], t['consumer_secret'], t['access_token'], t['access_token_secret'])
			d = @c.cfg['mysql2']
			@d = Database::DBHandler.new(:host => d['host'], :port => d['port'], :dbname => d['dbname'])
			@d.link(d['username'], d['password'])
			@d.create_if_not_exists(d['tablename'])
			@tablename = d['tablename']
		end

		def write_init_marker
			@d.insert_into(@tablename, :id => nil,
              :marker => 1,
              :marker_msg => "recording started", 
              :userid => nil,
              :username => nil,
              :tweetid => nil,
              :tweet => nil,
              :date => nil,
              :rt_count => 0,
              :fav_count => 0)
		end

		def write_halt_marker
			@d.insert_into(@tablename, :id => nil,
				:marker => 1,
				:marker_msg => "recording started", 
				:userid => nil,
				:username => nil,
				:tweetid => nil,
				:tweet => nil,
				:date => nil,
				:rt_count => 0,
				:fav_count => 0)
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
				# TODO: add downloader (in other thread)
				puts a['urls']
			}
		end
	end
end

if __FILE__ == $0
	main = Application::Main.new
	main.run
end
