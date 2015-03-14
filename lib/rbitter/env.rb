# encoding: utf-8

require "json"

module Rbitter
  @internal_configuration = {}

  class ConfigurationFileError < StandardError; end

  module_function
  def env
    @internal_configuration
  end

  def env_reset
    @internal_configuration.clear
  end

  def config_load path
    open(path, 'r') { |io|
      @internal_configuration = JSON.parse(io.read)
    }
    true
  end

  def config_initialize json_path=nil
    @internal_configuration = JSON.parse("{}")

    unless json_path.nil?
      begin
        config_load(json_path)
        # TODO: Configuration validation
        return @internal_configuration
      rescue => e
        fail ConfigurationFileError, "Provided configuration can not be loaded. (#{json_path})"
      end
    end

    # Configuration default location
    # Priorities
    # 1. (current_dir)/config.json
    # 2. (current_dir)/.rbitter/config.json
    locations = Array.new
    base_locations = ["config.json", ".rbitter/config.json"]

    base_locations.each { |bloc|
        locations.push File.join(Dir.pwd, bloc)
    }

    for location in locations
      next unless File.file?(location)
      break if config_load(location)
    end

    if @internal_configuration.empty?
      fail ConfigurationFileError, "Can not load any configuration in [#{locations.join(', ')}]"
    end
  end
end
