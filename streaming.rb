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
      puts "Network unavailable. restart in 3 seconds..."
      sleep 3
      retry
    rescue Exception => e
      puts "Exception (#{e.inspect})"
      sleep 3
      retry
    end
  end

  private
  def internal(&operation_block)
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
        begin
          operation_block.call(res)
        rescue Mysql2::Error => e
          puts "======================================"
          puts "Mysql2::Error exception caught. (#{e.to_s})"
          puts "It seemed to be an encoding exception. (given encoding : #{res['tweet'].encoding})"
          # XXX: RubyInstaller 2.1.1 encoding issue.
          #res['tweet'].encode!("UTF-8", "UTF-8", { :invalid => :replace, :undef => :replace, :replace => "?" })
        end
      end      
    end
  end
end
