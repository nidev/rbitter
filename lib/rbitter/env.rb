# encoding: utf-8

require "json"

module Rbitter
  @@env = Hash.new

  class ConfigFileError < StandardError; end

  def self.[](k)
    @@env[k]
  end

  module_function
  def env
    @@env
  end

  def env_reset
    @@env.clear
  end

  def env_validate?
    # TODO: Add validator
    true
  end

  def config_initialize json_path=nil
    env_reset

    unless json_path.nil?
      begin
        open(json_path, 'r') { |file|
          @@env = JSON.parse(file.read)
        }

        return @@env if env_validate?
        fail StandardError, "Invalid configuration"
      rescue => e
        fail ConfigFileError, "Load Failure (#{json_path}): #{e.to_s}"
      end
    end

    # Configuration default location
    # 1. (current_dir)/config.json
    # 2. (current_dir)/.rbitter/config.json
    locations = ["config.json", ".rbitter/config.json"]
    locations.collect! { |base| File.join(Dir.pwd, base) }

    for location in locations
      next unless File.file?(location)
      open(location, 'r') { |file|
        @@env = JSON.parse(file.read)
      }
      break if env_validate?
    end

    if @@env.empty?
      fail ConfigFileError, "Can not load any configuration in [#{locations.join(', ')}]"
    end
  end
end
