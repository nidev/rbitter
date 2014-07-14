# encoding: utf-8

require 'twitter'

class StreamClient
	def initialize(ck, cs, at, ats)
		@t = Twitter::Streaming::Client.new do |object|
			object.consumer_key        = ck
			object.consumer_secret     = cs
			object.access_token        = at
			object.access_token_secret = ats
		end
	end

	def run(&operation_block)
		@t.user do |tweet|
			if tweet.is_a?(Twitter::Tweet)
				text = tweet.full_text.gsub(/(\r\n|\n)/, '')

				# unpack uris and media links
				urls = Array.new

				if tweet.entities?
					if tweet.media?
						tweet.media.each { |uri|
							urls.push("#{uri.media_uri_https}")
							text.gsub!("#{uri.uri}", "#{uri.media_uri_https}")
						}
					end

					if tweet.uris?
						tweet.uris.each { |uri|
							urls.push("#{uri.expanded_url}")
							text.gsub!("#{uri.url}", "#{uri.expanded_url}")
						}
					end
				end

				res = {
					"tweetid" => tweet.id,
					"userid" => tweet.user.id,
					"tweet" => text,
					"rt_count" => tweet.retweet_count,
					"fav_count" => tweet.favorite_count,
					"screen_name" => tweet.user.screen_name,
					"date" => tweet.created_at,
					"urls" => urls
				}
				operation_block.call(res)
			end			
		end
	end
end
