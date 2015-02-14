# encoding: utf-8
#

require "base64"
require_relative "base"

module RPCHandles
  class ImageHost < BaseHandle::Auth
    attr_accessor :desc
    def initialize
      @desc = RH_INFO.new("imghost", "0.1", "nidev", "Host images downloaded from Tweets.")
      puts @desc.digest

      @imgroot = File.expand_path(Rbitter.env['media_downloader']['download_dir'])
    end

    def image link_or_filename
      exact_fname = File.basename(link_or_filename)
      imgpath = File.join(@imgroot, exact_fname)
      if exact_fname.empty? or not File.exist?(imgpath)
        ""
      else
        b64_data = open(imgpath, 'rb') { |io|
          Base64.encode64(io.read)
        }
        b64_data
      end
    end
  end
end
