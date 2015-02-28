# encoding: utf-8

require "json"

module Rbitter
  @internal_configuration = Hash.new

  module_function
  def env
    @internal_configuration
  end

  def config_load path
    # TODO: synchronizing
    open(path, 'r') { |io|
      @internal_configuration = JSON.parse(io.read)
      @internal_configuration.freeze
    }
    true
  end

  def config_initialize json_path=nil
    @internal_configuration = JSON.parse("{}")

    unless json_path.nil?
      begin
        config_load(path) if File.file?(json_path)
        # TODO: Configuration validation
        return @internal_configuration
      rescue => e
        puts "Provided configuration can not be loaded. (#{json_path})"
        puts "Rbitter will find default locations..."
      end
    end

    # Configuration default location
    # Priorities
    # 1. $HOME/config.json
    # 2. $HOME/.rbitter/config.json
    # 3. (current_dir)/config.json
    # 4. (current_dir)/.rbitter/config.json
    locations = Array.new
    base_locations = ["config.json", ".rbitter/config.json"]
    if ENV['HOME']
      base_locations.each { |bloc|
        locations.push File.join(ENV['HOME'], bloc)
      }
    end

    base_locations.each { |bloc|
        locations.push File.join(Dir.pwd, bloc)
    }

    for location in locations
      next unless File.file?(location)
      break if config_load(location)
    end

    if @internal_configuration.empty?
      # TODO: New exception class
      fail StandardError, "Can not load any configuration in [#{locations.join(', ')}]"
    end
  end
end
