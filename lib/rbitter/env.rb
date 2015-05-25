# encoding: utf-8

require "json"
require "rbitter/default/config_json"

module Rbitter
  @@env = Hash.new

  class ConfigFileError < StandardError; end
  class MissingFieldError < StandardError; end

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

  def env_listfields hash
    path_stack = ['']
    generated = []

    until path_stack.empty?
      path = path_stack.pop

      if path == ''
        o = hash
      else
        nodes = path.strip.split('->')
        o = hash
        until nodes.empty?
          o = o[nodes.shift]
        end
      end

      o.each_key { |k|
        if o[k].is_a?(Hash)
          path_stack << "#{k}" if path.empty?
          path_stack << path + "->#{k}" unless path.empty?
        else
          generated << "#{k}" if path.empty?
          generated << path + "->#{k}" unless path.empty?
        end
      }
    end

    generated
  end

  def env_valid?
    defaults = env_listfields(JSON.parse(DEFAULT_CONFIG_JSON))
    currents = env_listfields(@@env)
    not_errored = true

    # Cross checking (2 phases)
    # In current exists, default does not: redundant configuration
    # Level: warning since it is not utilized at all.
    currents.each { |conf|
      unless defaults.include?(conf)
        warn "[config.json] Unused config: #{conf}. You can safely remove it."
      end
    }

    # In default exists, current does not: missing configuration
    # Level: error and program should stop. (return false for this)
    defaults.each { |conf|
      unless currents.include?(conf)
        warn "[config.json] Config not found: #{conf}. Invalid configuration!"
        not_errored = false
      end
    }
    not_errored
  end

  def config_initialize json_path=nil
    env_reset

    unless json_path.nil?
      begin
        open(json_path, 'r') { |file|
          @@env = JSON.parse(file.read)
        }

        return @@env if env_valid?
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
      break if env_valid?
    end

    fail ConfigFileError, "No config.json on #{locations.join(' or ')}" if @@env.empty?
    fail ConfigFileError, "Configuration outdated. Please see above messages to update it" if not env_valid?

    puts "[config.json] Loaded configuration is valid. good to go!"
  end
end
