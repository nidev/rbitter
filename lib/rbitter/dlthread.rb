# encoding: utf-8

require "net/http"
require "openssl"

module Rbitter
  class DLThread
    MAX_THREADS = 20

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
      if @pool.length >= MAX_THREADS
        job_cleanup
      else
        puts "[dlthread] Stacked threads: #{@pool.length}"
      end

      download_task = Thread.new do
        url_array.each { |url|
          uri = URI.parse(@large_image ? url + ":large" : url) 

          Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme.downcase == 'https') { |h|
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
      end

      @pool.push download_task
    end

    def job_cleanup
      until @pool.empty?
        dlthrd = @pool.shift
        
        puts "[dlthread] Finishing thread [remains: #{@pool.length}]"
        if dlthrd.join(5).nil?
          puts "[dlthread] #{dlthrd.to_s} is still running. (timeout: 5sec)"
        end
      end
    end
  end
end
