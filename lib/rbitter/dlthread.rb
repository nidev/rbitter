# encoding: utf-8

require "net/http"
require "openssl"

module Rbitter
  class DLThread
    def initialize(dlfolder, large_flag)
      @dest = dlfolder
      if not File.directory?(dlfolder)
        warn "[dlthread] Given download location is not available for downloading."
        warn "[dlthread] Fallback to current directory."
        @dest = "./"
      end

      if large_flag.nil?
        @large_image = false
      else
        @large_image = large_flag
      end

      @pool = Array.new
    end

    def <<(url_array)
      download_task = Thread.new {
        url_array.each { |url|
          uri = URI.parse(@large_image ? url + ":large" : url) 
          ssl = uri.scheme.downcase == 'https'

          Net::HTTP.start(uri.host, uri.port, :use_ssl => ssl) { |h|
            req = Net::HTTP::Get.new uri.request_uri
            h.request(req) { |res|
              case res
              when Net::HTTPOK
                fname = File.basename(url)

                puts "[fetch] remote: #{uri.path} => local: #{fname}"
                open(File.join(@dest, fname), "wb") { |file|
                  res.read_body { |chunk| file.write(chunk) }
                }
              end
            }
          }
        }
      }

      @pool.push download_task
    end

    def job_cleanup
      until @pool.empty?
        dlthrd = @pool.shift

        if dlthrd.alive?
          puts "[dlthread] Thread forceful cleaning up [remains: #{@pool.length}]"
          dlthrd.terminate
          dlthrd.join
        end
      end
    end
  end
end