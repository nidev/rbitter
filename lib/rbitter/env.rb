# encoding: utf-8

require "json"

module Rbitter
  @env = Hash.new

  class ConfigFileError < StandardError; end

  module_function
  def [](k)
    @env[k]
  end

  def env
    @env
  end

  def env_reset
    @env.clear
  end

  def config_load path
    open(path, 'r') { |file|
      @env = JSON.parse(file.read)
    }
    true
  end

  def config_initialize json_path=nil
    @env = JSON.parse("{}")

    unless json_path.nil?
      begin
        config_load(json_path)
        # TODO: Configuration validation
        return @env
      rescue => e
        fail ConfigFileError, "Provided configuration can not be loaded. (#{json_path})"
      end
    end

    # Configuration default location
    # 1. (current_dir)/config.json
    # 2. (current_dir)/.rbitter/config.json
    locations = ["config.json", ".rbitter/config.json"]
    locations.collect! { |base| File.join(Dir.pwd, base) }

    for location in locations
      next unless File.file?(location)
      break if config_load(location)
    end

    if @env.empty?
      fail ConfigFileError, "Can not load any configuration in [#{locations.join(', ')}]"
    end
  end
end
