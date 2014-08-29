# encoding: utf-8

require "net/http"
require "openssl"

class DLThread
  def initialize(dlfolder)
    @dest = dlfolder
    if not File.directory?(dlfolder)
      puts "[ Given location is not available for downloading ]"
      puts "[ Will save files on current folder.              ]"
      @dest = "./"
    end
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
        http.ca_file = './cacerts/cacert.pem'
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      http.request_get(uri.path) { |res|
        case res
        when Net::HTTPOK
          puts "<< #{uri.path} being downloaded"
          fname = File.basename(uri.path)
          if fname.nil? or fname.size < 1
            fname = uri.path.gsub(/\//, "_")
          end
          puts "write into #{fname}"
          File.open(@dest+"/"+fname, "wb") { |file|
            res.read_body { |chunk|
              file.write(chunk)
            }
          }
          puts "<< #{uri.path} downloaded on #{@dest}"
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