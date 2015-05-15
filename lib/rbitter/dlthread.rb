# encoding: utf-8

require "net/http"
require "openssl"

module Rbitter
  class DLThread
    def initialize(dlfolder, cacert_path, large_flag)
      @dest = dlfolder
      if not File.directory?(dlfolder)
        warn "[dlthread] Given download location is not available for downloading."
        warn "[dlthread] Fallback to current directory."
        @dest = "./"
      end

      @cacert = cacert_path

      unless File.exist?(@cacert)
        fail StandardError, "Can not load ca-certificate file from #{cacert_path}"
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
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme.downcase == 'https'
            http.use_ssl = true
            http.ca_path = @cacert
          end

          begin
            http.request_get(uri.path) { |res|
              case res
              when Net::HTTPOK
                fname = File.basename(url)

                puts "[fetch] remote: #{uri.path} => local: #{fname}"
                open(File.join(@dest, fname), "wb") { |file|
                  res.read_body { |chunk| file.write(chunk) }
                }
              end
            }
          rescue OpenSSL::SSL::SSLError => e
            warn "[dlthread] Invalid SSL cert. Can not make secure connection."
          end
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