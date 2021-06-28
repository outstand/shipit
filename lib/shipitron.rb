require 'shipitron/version'
require 'hashie'
require 'shipitron/logger'
require 'metaractor'
require 'shipitron/smash'

module Shipitron
  CONFIG_FILE = 'shipitron/config.yml'.freeze
  SECRETS_FILE = '~/.config/shipitron/secrets.yml'.freeze
  GLOBAL_CONFIG_FILE = '~/.config/shipitron/config.yml'.freeze

  class << self
    def config_file
      @config_file ||= CONFIG_FILE
    end

    def config_file=(file)
      @config_file = file
    end

    def config
      @config ||= Smash.load(Pathname.new(config_file).expand_path.to_s).merge(secrets).merge(global_config)
    rescue ArgumentError
      Logger.warn "Config file '#{config_file}' does not exist"
      @config = secrets.merge(global_config)
    end

    def secrets_file
      @secrets_file ||= SECRETS_FILE
    end

    def secrets_file=(file)
      @secrets_file = file
    end

    def secrets
      @secrets ||= Smash.load(Pathname.new(secrets_file).expand_path.to_s)
    rescue ArgumentError
      Logger.warn "Secrets file '#{secrets_file}' does not exist"
      @secrets = Smash.new
    end

    def global_config_file
      @global_config_file ||= GLOBAL_CONFIG_FILE
    end

    def global_config_file=(file)
      @global_config_file = file
    end

    def global_config
      @global_config ||= Smash.load(Pathname.new(global_config_file).expand_path.to_s)
    rescue ArgumentError
      Logger.warn "Global config file '#{global_config_file}' does not exist"
      @global_config = Smash.new
    end
  end
end
