# encoding: utf-8

module Rbitter
  class ConfigLoader
    def initialize(cfg_filename='config.json')
      File.open(cfg_filename, "r") { |file|
        @cfg = JSON.parse(file.read)
        @cfg.freeze # no modification can be made.
      }
    end

    def method_missing(method_name, *args)
      if method_name.class == String
        method_name = method_name.to_sym
      end
      
      @cfg.__send__(method_name, *args)
    end
  end
end
