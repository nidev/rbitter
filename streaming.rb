# encoding: utf-8

require 'twitter'

class StreamClient
  def initialize(tokens)
    @t = Twitter::Streaming::Client.new do |object|
      object.consumer_key        = tokens['consumer_key']
      object.consumer_secret     = tokens['consumer_secret']
      object.access_token        = tokens['access_token']
      object.access_token_secret = tokens['access_token_secret']
    end
  end

  def run(&operation_block)
    begin
      internal(&operation_block)
    rescue EOFError => e
      puts "Network unreachable. Retry in 3 seconds..."
      sleep 3
      retry
    end
  end

  private
  def internal(&operation_block)
    @t.user do |tweet|
      if tweet.is_a?(Twitter::Tweet)
        if tweet.retweet?
          tweet = tweet.retweeted_tweet
        end

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
              #urls.push("#{uri.expanded_url}")
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
        
        #if tweet.retweet?
        #  res["rt_count"] = tweet.retweeted_tweet.retweet_count
        #  res["fav_count"] = tweet.retweeted_tweet.favorite_count
        #end
        operation_block.call(res)
      end      
    end
  end
end
