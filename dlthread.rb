# encoding: utf-8

require "net/http"
require "openssl"

class DLThread
  def initialize(dlfolder, cacert_path)
    @dest = dlfolder
    if not File.directory?(dlfolder)
      puts "[ Given location is not available for downloading ]"
      puts "[ Will save files on current folder.              ]"
      @dest = "./"
    end

    @cacert = cacert_path
  end

  def execute_urls(urls)
    urls.each { |url|
      download_once(url)
    }
  end

  private
  def download_once(url)
    download_task = Thread.new {
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme.downcase == 'https'
        http.use_ssl = true
        http.ca_path = @cacert_path
        # XXX: Fix this soon as possible.
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      http.request_get(uri.path) { |res|
        case res
        when Net::HTTPOK
          fname = File.basename(uri.path)
          if fname.nil? or fname.size < 1
            fname = uri.path.gsub(/\//, "_")
          end
          puts "[fetch] remote: #{url} => local: #{fname}"
          File.open(@dest+"/"+fname, "wb") { |file|
            res.read_body { |chunk|
              file.write(chunk)
            }
          }
        end
      }
    }

    download_task.run
  end
end


if __FILE__ == $0
  t = DLThread.new(".")
  t.execute_urls(["https://www.google.co.kr/images/nav_logo195.png"])
  sleep 4
end
